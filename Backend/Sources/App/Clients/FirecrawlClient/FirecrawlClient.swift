// FirecrawlClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Vapor

struct FirecrawlClient {
    private let client: Client
    private let baseUrl: String
    private let apiKey: String

    public init(client: Client) {
        self.client = client
        baseUrl = try! Environment
            .getOrThrow("FIRECRAWL_BASE_URL") // Error handling can be improved based on your app structure
        apiKey = try! Environment.getOrThrow("FIRECRAWL_SELFHOST_API_KEY") // Same here
    }

    func scrapeMarkdown(from input: ScrapeMarkdownInput) async throws -> WebsiteResponseItem {
        let url = try createScrapeUrl()
        let headers = try createHeaders()

        let response = try await client.post(
            .init(string: url.absoluteString),
            headers: headers,
            content: input
        )

        guard let responseBody = response.body, response.status == .ok else {
            throw FirecrawlClientErrors.failedToScrape
        }

        let responseData = Data(buffer: responseBody)
        let decodedData = try responseData.decodeAsJSON(type: FirecrawlScrapeResult.self)

        let images = getMarkdownImageUrls(from: decodedData.data.markdown)

        let validUrls = decodedData.data.links.reduce(into: [String]()) { result, link in
            if URL(string: link) != nil, !link.starts(with: "#") {
                result.append(link)
            }
        }

        return .init(
            links: validUrls,
            markdown: decodedData.data.markdown,
            imageUrls: images
        )
    }

    private func getMarkdownImageUrls(from markdown: String) -> [String] {
        let pattern = #"!\[.*?\]\((https?:\/\/[^\s)]+)\)"#

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: markdown, options: [], range: NSRange(markdown.startIndex..., in: markdown))

            return matches.compactMap { match in
                if let range = Range(match.range(at: 1), in: markdown) {
                    return String(markdown[range])
                }
                return nil
            }
        } catch {
            return []
        }
    }

    private func createScrapeUrl() throws -> URL {
        guard let url = URL(string: "\(baseUrl)/v1/scrape") else {
            throw GenericErrors.invalidUrl
        }
        return url
    }

    private func createHeaders() throws -> HTTPHeaders {
        .init([
            ("Content-Type", "application/json"),
            ("x-api-key", apiKey),
        ])
    }

    // NOTE: We still have these routes to implement
    // These might be used in the future and can be implemented then!
    // startCrawl()
    // getCrawlResults()
}
