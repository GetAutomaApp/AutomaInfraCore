// FirecrawlClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

//
//  Untitled.swift
//  Backend
//
//  Created by Simon Ferns on 3/9/25.
//
import DataTypes
import Vapor

struct FirecrawlClient {
    private let client: Client

    public init(client: Client) {
        self.client = client
    }

    func scrapeMarkdown(from input: ScrapeMarkdownInput) async throws -> WebsiteResponseItem {
        let baseUrl = try Environment.getOrThrow("FIRECRAWL_BASE_URL")

        guard let url = URL(string: "\(baseUrl)/v1/scrape") else {
            throw GenericErrors.invalidUrl
        }

        let response = try await client.post(
            .init(string: url.absoluteString),
            headers: .init([
                (
                    "Content-Type", "application/json"
                ),
            ]),
            content: input
        )

        guard let responseBody = response.body, response.status == .ok else {
            throw FirecrawlClientErrors.failedToScrape
        }

        let responseData = Data(buffer: responseBody)
        let decodedData = try responseData.decodeAsJSON(
            type: FirecrawlScrapeResult.self
        )

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
}
