// RSSFeedReaderClientTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

@Suite("RSSFedReaderClientTests")
struct RSSFeedReaderClientTests {
    private func withApp(test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test(
        "Get feed items when feed exists",
        arguments: [
            (URL(string: "https://news.ycombinator.com/rss")!, true), // rss format
            (URL(string: "https://sample-feeds.rowanmanning.com/examples/222780a7caac12b938dfe09cd7d138f9/feed.xml")!, true), // atom feed
            (URL(string: "https://example.com")!, false),
            (URL(string: "https://invalid-feed.com")!, false),
        ]
    )
    func getFeedItemsWhenFeedExists(url: URL, feedExists: Bool) async throws {
        try await withApp { app in
            let client = RSSFeedReaderClient(logger: app.logger)
            let result = try await client.read(from: url)
            if feedExists {
                try #require(result.items.count > 0, "Feed should have items")
                for item in result.items {
                    #expect(item.title != "", "Item title should not be empty")
                }
            } else {
                #expect(result.items.isEmpty, "Feed should not exist")
            }
        }
    }
}
