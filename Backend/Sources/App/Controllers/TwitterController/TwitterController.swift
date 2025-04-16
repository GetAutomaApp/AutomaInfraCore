// TwitterController.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Vapor

internal struct TwitterController: RouteCollection {
    public func boot(routes: RoutesBuilder) throws {
        let twitterRoute = routes.grouped("Twitter")

        twitterRoute.get("redirect", use: redirect)
        twitterRoute.post("post", use: post)
    }

    @Sendable
    public func redirect(req: Request) async throws -> String {
        let twitterClient = try TwitterClient(logger: req.logger, client: req.client, database: req.db)
        let queryParameters = try req.query.decode(TwitterOAuthRedirectQueryParameters.self)

        let userTokens = try await twitterClient.auth.getUserTokens(
            oauthToken: queryParameters.oauthToken,
            oauthVerifier: queryParameters.oauthVerifier
        )

        req.logger.info("User Access Token: \(userTokens.accessToken)")
        req.logger.info("User Refresh Token: \(userTokens.accessToken)")

        let dto = userTokens.toDTO()
        return try dto.encodeToData().base64EncodedString()
    }

    @Sendable
    public func post(req: Request) async throws -> HTTPStatus {
        let token = try TwitterClient.getUserToken(req: req)

        let authenticatedClient = try TwitterClient(
            logger: req.logger,
            client: req.client,
            database: req.db
        ).authenticated(token: token)

        let content = try req.content.decode(PostTweetContent.self)
        let response = try await authenticatedClient.postTweet(message: content.message)
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
