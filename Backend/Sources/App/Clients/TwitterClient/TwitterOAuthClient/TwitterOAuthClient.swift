// TwitterOAuthClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Foundation
import TwitterAPIKit
import Vapor

struct TwitterOAuthClient: TwitterClientBase {
    let logger: Logger
    let client: Client
    let database: Database
    let twitterClient: TwitterAPIClient
    var callbackURL: String

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

    public func requestToken() async throws -> TwitterOAuthToken {
        let response = twitterClient.auth.oauth10a
            .postOAuthRequestToken(.init(
                oauthCallback: callbackURL
            ))
        guard
            let tokenObject = await response.responseObject.success
        else {
            throw Abort(.internalServerError)
        }
        let savedToken = try await saveOAuthToken(tokenObject: tokenObject)

        BackendMetric.totalTwitterOAuthRequests.increment()

        return savedToken
    }

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

            throw Abort(.internalServerError)
        }

        // TODO: Use selenium to login user
        logger.info("Go to URL: \(authenticateURL) and authenticate.")
        return authenticateURL
    }

    public func getUserTokens(oauthToken: String, oauthVerifier: String) async throws -> TwitterUserToken {
        guard
            let oauthTokenObject = try await getOAuthTokenObject(fromOAuthToken: oauthToken)
        else {
            throw Abort(.unauthorized, reason: "Invalid OAuth token")
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
                    "tokenObject": .string(token.description),
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

    private func getOAuthTokenObject(fromOAuthToken oauthToken: String) async throws -> TwitterOAuthToken? {
        try await TwitterOAuthToken
            .query(on: database)
            .filter(\.$oauthToken, .equal, oauthToken)
            .first()
    }

    private func convertOAuthTokenToUserTokens(tokenObject: TwitterOAuthToken,
                                               oauthVerifier: String) async throws -> TwitterUserTokens
    {
        let response = await twitterClient.auth.oauth10a.postOAuthAccessToken(.init(
            oauthToken: tokenObject.oauthToken,
            oauthVerifier: oauthVerifier
        )).responseObject

        guard
            let success = response.success
        else {
            logger.error(
                "Failed to convert oauth token to user access token and user secret access token.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(response.error.debugDescription),
                    "oauthToken": .string(tokenObject.oauthToken),
                    "oauthTokenSecret": .string(tokenObject.oauthTokenSecret),
                    "oauthVerifier": .string(oauthVerifier),
                ]
            )

            throw Abort(
                .unauthorized,
                reason: response.error?
                    .localizedDescription ?? "Failed to obtain user access token and secret access token."
            )
        }

        BackendMetric.totalTwitterUserTokensConverted.increment()

        return .init(accessToken: success.oauthToken, secretAccessToken: success.oauthTokenSecret)
    }
}
