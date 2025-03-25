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
        "Test Read Feed Success",
        arguments: [
            URL(string: "https://news.ycombinator.com/rss")!, // rss format
            URL(string: "https://sample-feeds.rowanmanning.com/examples/222780a7caac12b938dfe09cd7d138f9/feed.xml")!,
            // atom feed
        ]
    )
    func testReadFeedSuccess(url: URL) async throws {
        try await withApp { app in
            let client = RSSFeedReaderClient(logger: app.logger)
            let result = try await client.read(from: url)
            for item in result.items {
                app.logger.info("Item: \(String(reflecting: item))")
                #expect(item.title != "", "Item title should not be empty")
            }
        }
    }
}
