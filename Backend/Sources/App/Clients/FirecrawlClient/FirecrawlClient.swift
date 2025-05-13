// FirecrawlClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Vapor

/// A client for scraping website content in markdown format using the Firecrawl microservice.
///
/// This client can bypass captchas and proxies if configured in the microservice.
/// The microservice is available at: https://github.com/GetAutomaApp/firecrawl-clone
internal struct FirecrawlClient {
    /// The HTTP client used for making requests to the Firecrawl microservice.
    private let client: Client

    /// Logger for recording events and errors during scraping operations.
    private let logger: Logger

    /// Base URL for the Firecrawl microservice.
    private let baseUrl: String

    /// API key for authenticating requests to the Firecrawl microservice.
    private let apiKey: String

    /// Initializes a new instance of the FirecrawlClient.
    ///
    /// - Parameters:
    ///   - client: The HTTP client used for making requests.
    ///   - logger: Logger for recording events and errors.
    /// - Throws: An error if the environment variables for base URL or API key are not set.
    public init(client: Client, logger: Logger) throws {
        self.client = client
        self.logger = logger

        baseUrl = try Environment.getOrThrow("FIRECRAWL_BASE_URL")
        apiKey = try Environment.getOrThrow("FIRECRAWL_SELFHOST_API_KEY")
    }

    /// Scrapes markdown content from a given URL using the Firecrawl microservice.
    ///
    /// - Parameter input: The input containing the URL to scrape.
    /// - Returns: A `WebsiteResponseItem` containing links, markdown content, and image URLs.
    /// - Throws: An error if the scraping operation fails.
    public func scrapeMarkdown(from input: ScrapeMarkdownInput) async throws -> WebsiteResponseItem {
        BackendMetric
            .firecrawlScrapeMarkdown(status: .start, url: input.url)
            .increment()

        do {
            let url = try createScrapeUrl()
            let headers = try createHeaders()

            // Sends a POST request to the Firecrawl microservice with the input data
            let response = try await client.post(
                .init(string: url.absoluteString),
                headers: headers,
                content: input
            )

            // Decodes the response content into a FirecrawlScrapeResult
            guard let decodedData = try? response.content.decode(FirecrawlScrapeResult.self) else {
                logger.error(
                    "Invalid response from firecrawl microservice",
                    metadata: [
                        "url": .string(input.url),
                        "description": .string(
                            response.body?.debugDescription ?? response.description
                        ),
                        "to": .string("FirecrawlClient.scrapeMarkdown"),
                    ]
                )
                throw FirecrawlClientError.failedToScrape
            }

            // Extracts image URLs from the markdown content
            let images = getMarkdownImageUrls(from: decodedData.data.markdown)

            // Filters valid URLs from the response links
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
                    "error": .string(error.localizedDescription),
                    "to": .string("FirecrawlClient.scrapeMarkdown"),
                ]
            )
            throw error
        }
    }

    /// Extracts image URLs from markdown content using regular expressions.
    ///
    /// - Parameter markdown: The markdown content to extract image URLs from.
    /// - Returns: An array of image URLs found in the markdown content.
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
            logger.error(
                "Unexpected error while extracting markdown image urls",
                metadata: [
                    "to": .string("FirecrawlClient.getMarkdownImageUrls"),
                    "error": .string(error.localizedDescription),
                ]
            )
            return []
        }
    }

    /// Creates the URL for the scrape request to the Firecrawl microservice.
    ///
    /// - Returns: The URL for the scrape request.
    /// - Throws: An error if the URL is invalid.
    private func createScrapeUrl() throws -> URL {
        guard let url = URL(string: "\(baseUrl)/v1/scrape") else {
            throw GenericErrors.invalidUrl
        }
        return url
    }

    /// Creates the HTTP headers for the scrape request.
    ///
    /// - Returns: The HTTP headers including content type and API key.
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

/// An enumeration representing the formats supported by the FirecrawlClient.
///
/// This enum defines the content formats that can be scraped by the FirecrawlClient,
/// including markdown and raw HTML.
public enum FirecrawlFormats: String, Content {
    /// Represents content in markdown format.
    case markdown

    /// Represents content in raw HTML format.
    case rawHtml
}

/// A structure representing the input required for scraping markdown content.
///
/// This struct is used to encapsulate the URL from which markdown content will be scraped.
public struct ScrapeMarkdownInput: Content {
    /// The URL of the website to scrape.
    public let url: String
}

/// A structure representing the result of a data scrape operation.
///
/// This struct contains the scraped markdown content and any links found within it.
public struct FirecrawlDataResult: Content {
    /// The markdown content scraped from the website.
    public let markdown: String

    /// The list of links extracted from the markdown content.
    public let links: [String]
}

/// A structure representing the result of a scrape operation.
///
/// This struct contains the success status of the operation and the data result.
public struct FirecrawlScrapeResult: Content {
    /// Indicates whether the scrape operation was successful.
    public let success: Bool

    /// The data result containing markdown and links.
    public let data: FirecrawlDataResult
}

/// A structure representing the response item from a website scrape.
///
/// This struct contains the links, markdown content, and image URLs extracted from the website.
public struct WebsiteResponseItem: Content {
    /// The list of links extracted from the website.
    public let links: [String]

    /// The markdown content extracted from the website.
    public let markdown: String

    /// The list of image URLs extracted from the markdown content.
    public let imageUrls: [String]
}
