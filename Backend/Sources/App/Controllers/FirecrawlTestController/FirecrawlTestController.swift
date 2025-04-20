// FirecrawlTestController.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

/// Controller for testing Firecrawl functionality.
internal struct FirecrawlTestController: RouteCollection {
    /// Registers routes for Firecrawl test operations.
    /// - Parameter routes: The routes builder to register routes on.
    public func boot(routes: RoutesBuilder) throws {
        let feedTesterRoute = routes.grouped("Firecrawl-Test")

        feedTesterRoute.get("request", use: request)
    }

    /// Handles requests to scrape markdown from a specified URL.
    /// - Parameter req: The request object.
    /// - Returns: A `WebsiteResponseItem` containing the scraped data.
    /// - Throws: An error if the scraping operation fails.
    @Sendable
    public func request(req: Request) async throws -> WebsiteResponseItem {
        let firecrawlClient = try FirecrawlClient(
            client: req.client,
            logger: req.logger
        )
        return try await firecrawlClient.scrapeMarkdown(
            from: .init(url: "https://firecrawl.dev")
        )
    }
}
