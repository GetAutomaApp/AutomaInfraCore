// ArticleContentScraperServiceIntegrationTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

@Suite("ArticleContentScraperServiceIntegrationTests")
internal struct ArticleContentScraperServiceIntegrationTests {
    public func withApp(test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Scrape Article Content Success")
    public func scrapeArticleContentSuccess() async throws {
        try await withApp { app in
            let article = try await ArticleContentScraperService(client: app.client, logger: app.logger)
                .scrapeArticle(payload: .init(
                    url: URL.fromString(
                        payload: .init(
                            string: "https://www.digitalocean.com/resources/articles/gpt-5-overview"
                        )
                    ),
                    scrollToBottom: true
                ))

            app.logger.info(
                "Article Inspection Log.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "article": .string(String(reflecting: article))
                ]
            )
        }
    }
}
