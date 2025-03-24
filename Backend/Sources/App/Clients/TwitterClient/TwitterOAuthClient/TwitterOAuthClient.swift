// TwitterOAuthClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Foundation
import TwitterAPIKit
import Vapor

/// A client for handling Twitter OAuth 1.0a authentication flow.
/// This client manages the OAuth token request, authentication URL generation,
/// and conversion of OAuth tokens to user access tokens.
struct TwitterOAuthClient: TwitterClientBase {
    let logger: Logger
    let client: Client
    let database: Database
    let twitterClient: TwitterAPIClient
    var callbackURL: String

    /// Initializes a new TwitterOAuthClient.
    /// - Parameters:
    ///   - logger: Logger instance for tracking operations
    ///   - client: HTTP client for making requests
    ///   - database: Database instance for token storage
    ///   - twitterClient: Twitter API client instance
    ///   - callbackURL: OAuth callback URL for the authentication flow
    public init(
        logger: Logger,
        client: Client,
        database: Database,
        twitterClient: TwitterAPIClient,
        callbackURL: String
    ) {
        self.logger = logger
        self.client = client
        self.database = database
        self.twitterClient = twitterClient
        self.callbackURL = callbackURL
    }

    /// Requests a new OAuth token from Twitter.
    /// - Returns: A TwitterOAuthToken instance if successful
    /// - Throws: TwitterOAuthClientError if the request fails
    public func requestToken() async throws -> TwitterOAuthToken {
        BackendMetric.twitterOAuthRequest(status: .start).increment()
        let response = twitterClient.auth.oauth10a
            .postOAuthRequestToken(.init(
                oauthCallback: callbackURL
            ))
        guard
            let tokenObject = await response.responseObject.success
        else {
            BackendMetric.twitterOAuthRequest(status: .fail).increment()
            let message = "Failed to obtain request token."
            guard
                let error = await response.responseObject.error
            else {
                throw TwitterOAuthClientError.unknown(
                    error: Abort(.custom(
                        code: 500,
                        reasonPhrase: message
                    ))
                )
            }
            logger.error(
                .init(stringLiteral: message),
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(String(reflecting: error)),
                ]
            )
            throw TwitterOAuthClientError.responseError(error)
        }

        let savedToken = try await saveOAuthToken(tokenObject: tokenObject)

        BackendMetric.twitterOAuthRequest(status: .success).increment()

        return savedToken
    }

    /// Generates the authentication URL for the user to authorize the application.
    /// - Parameter tokenObject: The OAuth token object obtained from requestToken()
    /// - Returns: URL that the user should visit to authorize the application
    /// - Throws: TwitterOAuthClientError if URL generation fails
    public func makeAuthenticateURL(tokenObject: TwitterOAuthToken) async throws -> URL {
        guard
            let authenticateURL = twitterClient.auth.oauth10a
            .makeOAuthAuthenticateURL(.init(oauthToken: tokenObject.oauthToken))
        else {
            logger.error(
                "Failed to make authenticateURL.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "oauthToken": .string("\(tokenObject.oauthToken)"),
                ]
            )
            throw TwitterOAuthClientError.unableToMakeAuthenticateURL
        }

        // TODO: Use selenium to login user
        logger.info(
            "Authenticate URL: \(authenticateURL) and authenticate.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "oauthToken": .string("\(tokenObject.oauthToken)"),
            ]
        )
        return authenticateURL
    }

    /// Converts OAuth tokens to user access tokens after successful authentication.
    /// - Parameters:
    ///   - oauthToken: The OAuth token received from Twitter
    ///   - oauthVerifier: The verification code received after user authorization
    /// - Returns: TwitterUserToken containing access tokens
    /// - Throws: TwitterOAuthClientError if token conversion fails
    public func getUserTokens(oauthToken: String, oauthVerifier: String) async throws -> TwitterUserToken {
        guard
            let oauthTokenObject = try await getOAuthTokenObject(fromOAuthToken: oauthToken)
        else {
            BackendMetric.twitterUserTokensConverted(status: .fail).increment()
            throw TwitterOAuthClientError.invalidOAuthToken
        }

        let userTokens =
            try await convertOAuthTokenToUserTokens(tokenObject: oauthTokenObject, oauthVerifier: oauthVerifier)
        let userTokenModel = try await saveUserTokens(
            userTokens: userTokens,
            oauthTokenObject: oauthTokenObject,
            oauthVerifier: oauthVerifier
        )

        return userTokenModel
    }

    /// Saves the user tokens to the database.
    /// - Parameters:
    ///   - userTokens: The tokens to be saved
    ///   - oauthTokenObject: The original OAuth token
    ///   - oauthVerifier: The verification code
    /// - Returns: The saved TwitterUserToken
    /// - Throws: Database errors if saving fails
    private func saveUserTokens(userTokens: TwitterUserTokens, oauthTokenObject: TwitterOAuthToken,
                                oauthVerifier: String) async throws -> TwitterUserToken
    {
        let userTokenModel = TwitterUserToken(
            accessToken: userTokens.accessToken,
            secretAccessToken: userTokens.secretAccessToken,
            oauthVerifier: oauthVerifier,
            oauthTokenID: oauthTokenObject.id
        )

        do {
            logger.info(
                "Saving Twitter user tokens to database.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "userTokenModel": .string(userTokenModel.description),
                ]
            )
            try await userTokenModel.save(on: database)
            return userTokenModel
        } catch {
            logger.error(
                "Failed to save requested Twitter user tokens to database.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "userTokens": .string(userTokenModel.description),
                    "error": .string(String(reflecting: error)),
                ]
            )
            throw error
        }
    }

    /// Saves an OAuth token to the database.
    /// - Parameter tokenObject: The OAuth token to save
    /// - Returns: The saved TwitterOAuthToken
    /// - Throws: Database errors if saving fails
    private func saveOAuthToken(tokenObject: TwitterOAuthTokenV1) async throws -> TwitterOAuthToken {
        let token = TwitterOAuthToken(
            oauthToken: tokenObject.oauthToken,
            oauthTokenSecret: tokenObject.oauthTokenSecret,
            oauthCallbackConfirmed: tokenObject.oauthCallbackConfirmed
        )
        do {
            logger.info(
                "Saving Twitter token to database.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "tokenObject": .string(String(reflecting: tokenObject)),
                ]
            )
            try await token.save(on: database)
        } catch {
            logger.error(
                "Failed to save requested Twitter token to database.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "tokenObject": .string(token.description),
                    "error": .string(String(reflecting: error)),
                ]
            )
            throw error
        }
        return token
    }

    /// Retrieves an OAuth token from the database.
    /// - Parameter oauthToken: The token string to look up
    /// - Returns: Optional TwitterOAuthToken if found
    /// - Throws: Database errors if query fails
    private func getOAuthTokenObject(fromOAuthToken oauthToken: String) async throws -> TwitterOAuthToken? {
        try await TwitterOAuthToken
            .query(on: database)
            .filter(\.$oauthToken, .equal, oauthToken)
            .first()
    }

    /// Converts an OAuth token to user access tokens.
    /// - Parameters:
    ///   - tokenObject: The OAuth token to convert
    ///   - oauthVerifier: The verification code from the OAuth process
    /// - Returns: TwitterUserTokens containing access and secret tokens
    /// - Throws: TwitterOAuthClientError if conversion fails
    private func convertOAuthTokenToUserTokens(tokenObject: TwitterOAuthToken,
                                               oauthVerifier: String) async throws -> TwitterUserTokens
    {
        BackendMetric.twitterUserTokensConverted(status: .start).increment()
        let response = await twitterClient.auth.oauth10a.postOAuthAccessToken(.init(
            oauthToken: tokenObject.oauthToken,
            oauthVerifier: oauthVerifier
        )).responseObject

        guard
            let success = response.success
        else {
            BackendMetric.twitterUserTokensConverted(status: .fail).increment()
            let message = "Failed to convert oauth token to user access token and user secret access token."

            guard
                let error = response.error
            else {
                logger.error(
                    .init(stringLiteral: message),
                    metadata: [
                        "to": .string("\(String(describing: Self.self)).\(#function)"),
                        "tokenObject": .string(tokenObject.description),
                    ]
                )

                throw TwitterOAuthClientError.unknown(
                    error: Abort(.custom(
                        code: 500,
                        reasonPhrase: message
                    ))
                )
            }

            logger.error(
                .init(stringLiteral: message),
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(String(reflecting: error)),
                    "tokenObject": .string(tokenObject.description),
                ]
            )

            throw TwitterOAuthClientError.responseError(error)
        }

        BackendMetric.twitterUserTokensConverted(status: .success).increment()

        return .init(accessToken: success.oauthToken, secretAccessToken: success.oauthTokenSecret)
    }
}
