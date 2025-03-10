// FirecrawlTestController.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

//
//  FirecrawlTestController.swift
//  Backend
//
//  Created by Simon Ferns on 3/9/25.
//
import Vapor

struct FirecrawlTestController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let feedTesterRoute = routes.grouped("Firecrawl-Test")

        feedTesterRoute.get("request", use: request)
    }

    @Sendable
    func request(req: Request) async throws -> WebsiteResponseItem {
        let firecrawlClient = FirecrawlClient(client: req.client)
        let response = try await firecrawlClient.scrapeMarkdown(
            from: .init(url: "https://firecrawl.dev")
        )
        return response
    }
}
