// TwitterController.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Vapor

struct TwitterController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let twitterRoute = routes.grouped("Twitter")

        twitterRoute.get("redirect", use: redirect)
    }

    @Sendable
    func redirect(req: Request) async throws -> TwitterUserTokens {
        let twitterClient = try TwitterClient(logger: req.logger, client: req.client, database: req.db)
        let queryParameters = try req.query.decode(TwitterOAuthRedirectQueryParameters.self)

        let userTokens = try await twitterClient.auth.getUserTokens(
            oauthToken: queryParameters.oauthToken,
            oauthVerifier: queryParameters.oauthVerifier
        )

        req.logger.info("User Access Token: \(userTokens.accessToken)")
        req.logger.info("User Refresh Token: \(userTokens.accessToken)")

        return userTokens
    }
}
