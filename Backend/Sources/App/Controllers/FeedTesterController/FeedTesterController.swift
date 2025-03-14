// FeedTesterController.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

struct FeedTesterController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let feedTesterRoute = routes.grouped("Feed-Tester")

        feedTesterRoute.get("request", use: request)
        feedTesterRoute.get("add-to-user", use: addToUser)
    }

    @Sendable
    func request(req _: Request) async throws -> RssFeedResponse {
        let feedService: RSSFeedReaderClient = .init()
        let response = try! await feedService.read(from: URL(string: "https://news.ycombinator.com/rss")!)
        return response
    }

    @Sendable
    func addToUser(req: Request) async throws -> HTTPStatus {
        let feedService = RSSFeedService(database: req.dbWrite, client: req.client, logger: req.logger)
        if let url = URL(string: "https://news.ycombinator.com/rss") {
            let success = try await feedService.addFeedToUser(
                userId: UUID(uuidString: "562771bf-98a5-4cc4-83ba-5f618dc79546")!,
                feedUrl: url
            )
            return success ? .ok : .internalServerError
        }
        return .badRequest
    }
}
