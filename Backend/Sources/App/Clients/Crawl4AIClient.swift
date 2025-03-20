// Crawl4AIClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation

struct CrawlRequest: Codable {
    let urls: [String]
    let browserConfig: BrowserConfig?
    let crawlerConfig: CrawlerConfig?

    enum CodingKeys: String, CodingKey {
        case urls
        case browserConfig = "browser_config"
        case crawlerConfig = "crawler_config"
    }
}

struct BrowserConfig: Codable {
    let headless: Bool

    init(headless: Bool = true) {
        self.headless = headless
    }
}

struct CrawlerConfig: Codable {
    let stream: Bool

    init(stream: Bool = false) {
        self.stream = stream
    }
}

struct CrawlTaskId: Codable {
    let taskId: UUID

    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
    }
}

struct CrawlResult: Codable {
    let results: [Result]

    struct Result: Codable {
        let url: String
        let extractedContent: String?
        let markdown: String?

        enum CodingKeys: String, CodingKey {
            case url
            case extractedContent = "extracted_content"
            case markdown
        }
    }
}

class Crawl4AIClient {
    private let baseURL: URL
    private let apiKey: String
    private let session: URLSession

    init(baseURL: String = "http://localhost:11235", apiKey: String) {
        self.baseURL = URL(string: baseURL)!
        self.apiKey = apiKey
        session = URLSession.shared
    }

    func startCrawl(urls: [String], browserConfig: BrowserConfig? = nil,
                    crawlerConfig: CrawlerConfig? = nil) async throws -> CrawlTaskId
    {
        let request = CrawlRequest(urls: urls, browserConfig: browserConfig, crawlerConfig: crawlerConfig)

        var urlRequest = URLRequest(url: baseURL.appendingPathComponent("crawl"))
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        let decodedResponse = try decoder.decode(CrawlTaskId.self, from: data)
        return decodedResponse
    }

    func getCrawl
}

// Example usage:
/*
 let client = Crawl4AIClient(apiKey: "YOUR_API_KEY")

 Task {
 do {
 let result = try await client.crawl(urls: ["https://example.com"])
 print("Crawl success: \(result.success)")
 for item in result.results {
 print("URL: \(item.url)")
 print("Content: \(item.extractedContent ?? "")")
 print("Markdown: \(item.markdown ?? "")")
 }
 } catch {
 print("Error: \(error)")
 }
 }
 */
