// TwitterClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation
import TwitterAPIKit
import Vapor

struct TwitterClient {
    let logger: Logger
    let client: Client

    private let consumerKey: String
    private let consumerSecret: String
    private let twitterClient: TwitterAPIClient
    private let callbackURL: String

    init(logger: Logger, client: Client) throws {
        self.logger = logger
        self.client = client
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

    func requestToken() async throws -> TwitterOAuthTokenV1 {
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

        return tokenObject
    }

    // Use selenium to authenticate
    // 2. GET oauth/authenticate
    // 3. POST oauth/access_token
    func authenticate() {}
}
