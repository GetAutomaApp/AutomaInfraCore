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
    var twitterClient: TwitterAPIClient

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
}
