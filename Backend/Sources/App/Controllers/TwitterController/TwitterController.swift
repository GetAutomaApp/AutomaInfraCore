// TwitterController.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Vapor

struct PostTweetContent: Content {
    let message: String
}

struct TwitterController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let twitterRoute = routes.grouped("Twitter")

        twitterRoute.get("redirect", use: redirect)
        twitterRoute.get("post", use: post)
    }

    @Sendable
    func redirect(req: Request) async throws -> TwitterUserTokenDTO {
        let twitterClient = try TwitterClient(logger: req.logger, client: req.client, database: req.db)
        let queryParameters = try req.query.decode(TwitterOAuthRedirectQueryParameters.self)

        let userTokens = try await twitterClient.auth.getUserTokens(
            oauthToken: queryParameters.oauthToken,
            oauthVerifier: queryParameters.oauthVerifier
        )

        req.logger.info("User Access Token: \(userTokens.accessToken)")
        req.logger.info("User Refresh Token: \(userTokens.accessToken)")

        return userTokens.toDTO()
    }

    @Sendable
    func post(req: Request) async throws -> HTTPStatus {
        let authenticatedClient = try TwitterClient(
            logger: req.logger,
            client: req.client,
            database: req.db
        ).authenticated(token: req.content.decode(TwitterUserTokenDTO.self))

        let tweetContent = try req.query.decode(PostTweetContent.self)
        let response = try await authenticatedClient.postTweet(message: tweetContent.message)
        req.logger.info(
            "Tweet response",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "data": .string("\(response.data)"),
            ]
        )

        return .ok
    }
}
