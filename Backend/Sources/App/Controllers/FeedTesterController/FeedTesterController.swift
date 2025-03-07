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
    }

    @Sendable
    func request(req _: Request) async throws -> RssFeedResponse {
        let feedService: RSSFeedReaderClient = .init()
        let response = await feedService.read(from: URL(string: "https://news.ycombinator.com/rss")!)
        return response
    }
}
