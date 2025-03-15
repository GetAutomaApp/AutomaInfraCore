// TwitterClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Foundation
import TwitterAPIKit
import Vapor

struct TwitterClient: TwitterClientBase {
    let logger: Logger
    let client: Client
    let database: Database
    let auth: TwitterOAuthClient

    let callbackURL: String
    let twitterClient: TwitterAPIClient

    let consumerKey: String
    let consumerSecret: String

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
        auth = TwitterOAuthClient(
            logger: logger,
            client: client,
            database: database,
            twitterClient: twitterClient,
            callbackURL: callbackURL
        )
    }

    public func authenticated(token: TwitterUserTokenDTO) -> TwitterAuthenticatedClient {
        .init(
            logger: logger,
            client: client,
            database: database,
            twitterClient: .init(
                .oauth10a(
                    .init(
                        consumerKey: consumerKey,
                        consumerSecret: consumerSecret,
                        oauthToken: token.accessToken,
                        oauthTokenSecret: token.secretAccessToken
                    )
                )
            )
        )
    }

    public static func getUserToken(req: Request) throws -> TwitterUserTokenDTO {
        guard
            let tokenBase64String = req.headers.first(name: "Authorization")
        else {
            throw Abort(.unauthorized)
        }
        let data = Data(base64Encoded: tokenBase64String)

        do {
            let token = try TwitterUserTokenDTO.decodeJSONFromData(data: data)
            return token
        } catch {
            req.logger.error(
                "Failed to decode token from authorization header.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(error.localizedDescription),
                ]
            )
            throw Abort(.unauthorized)
        }
    }
}
