// TwitterClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Foundation
import TwitterAPIKit
import Vapor

public struct TwitterUserTokens: Content {
    let accessToken: String
    let secretAccessToken: String
}

struct TwitterClient {
    let logger: Logger
    let client: Client
    let database: Database

    private let consumerKey: String
    private let consumerSecret: String
    private let twitterClient: TwitterAPIClient
    private let callbackURL: String

    public init(logger: Logger, client: Client, database: Database) throws {
        self.logger = logger
        self.client = client
        self.database = database

        consumerKey = try Environment.getOrThrow("TWITTER_API_APP_KEY")
        consumerSecret = try Environment.getOrThrow("TWITTER_API_APP_SECRET_KEY")
        callbackURL = try "\(Environment.getOrThrow("BACKEND_URL"))/Twitter/redirect"

        twitterClient = TwitterAPIClient(.oauth10a(.init(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            oauthToken: nil,
            oauthTokenSecret: nil
        )))
    }

    public func requestToken() async throws -> TwitterOAuthToken {
        // 1. POST oauth/request_token (postOAuthRequestToken)
        let response = twitterClient.auth.oauth10a
            .postOAuthRequestToken(.init(
                oauthCallback: callbackURL
            )) // Rewrite your oauth callback url or scheme
        guard
            let tokenObject = await response.responseObject.success
        else {
            throw Abort(.internalServerError)
        }
        let savedToken = try await saveToken(tokenObject: tokenObject)
        return savedToken
    }

    // 2. Make authenticate URL (manually go to url and log in)
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

    public func getUserTokens(oauthToken: String, oauthVerifier: String) async throws -> TwitterUserTokens {
        guard
            let tokenObject = try await getTokenObject(fromOAuthToken: oauthToken)
        else {
            throw Abort(.unauthorized, reason: "Invalid OAuth token")
        }
        // convert oauth token to user access token and secret access token
        let userTokens = try await convertOAuthTokenToUserTokens(tokenObject: tokenObject, oauthVerifier: oauthVerifier)
        return userTokens
    }

    private func saveToken(tokenObject: TwitterOAuthTokenV1) async throws -> TwitterOAuthToken {
        let token = TwitterOAuthToken(
            oauthToken: tokenObject.oauthToken,
            oauthTokenSecret: tokenObject.oauthTokenSecret,
            oauthCallbackConfirmed: tokenObject.oauthCallbackConfirmed
        )
        do {
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

    private func getTokenObject(fromOAuthToken oauthToken: String) async throws -> TwitterOAuthToken? {
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

        return .init(accessToken: success.oauthToken, secretAccessToken: success.oauthTokenSecret)
    }
}
