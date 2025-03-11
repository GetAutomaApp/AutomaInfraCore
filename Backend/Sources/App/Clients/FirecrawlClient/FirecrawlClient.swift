// FirecrawlClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Vapor

// Scrapes website content in markdown format. This scraper can bypass captchas / proxies if configured in the
// microservice: https://github.com/GetAutomaApp/firecrawl-clone
struct FirecrawlClient {
    private let client: Client
    private let logger: Logger
    private let baseUrl: String
    private let apiKey: String

    public init(client: Client, logger: Logger) {
        self.client = client
        self.logger = logger

        baseUrl = try! Environment.getOrThrow("FIRECRAWL_BASE_URL")
        apiKey = try! Environment.getOrThrow("FIRECRAWL_SELFHOST_API_KEY")
    }

    func scrapeMarkdown(from input: ScrapeMarkdownInput) async throws -> WebsiteResponseItem {
        BackendMetric
            .firecrawlScrapeMarkdown(status: .start, url: input.url)
            .increment()

        do {
            let url = try createScrapeUrl()
            let headers = try createHeaders()

            let response = try await client.post(
                .init(string: url.absoluteString),
                headers: headers,
                content: input
            )

            guard let responseBody = response.body, response.status == .ok else {
                logger.error(
                    "Invalid response from firecrawl microservice",
                    metadata: [
                        "url": .string(input.url),
                        "response": .string(String(buffer: response.body ?? .init())),
                        "to": .string("FirecrawlClient.scrapeMarkdown"),
                    ]
                )
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

            BackendMetric
                .firecrawlScrapeMarkdown(status: .success, url: input.url)
                .increment()

            return .init(
                links: validUrls,
                markdown: decodedData.data.markdown,
                imageUrls: images
            )
        } catch {
            BackendMetric
                .firecrawlScrapeMarkdown(status: .fail, url: input.url)
                .increment()

            logger.error(
                "Couldn't scrape markdown content via firecrawl",
                metadata: [
                    "url": .string(input.url),
                    "to": .string("FirecrawlClient.scrapeMarkdown"),
                ]
            )
            throw error
        }
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
