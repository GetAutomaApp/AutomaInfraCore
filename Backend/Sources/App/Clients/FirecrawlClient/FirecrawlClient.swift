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

enum FirecrawlFormats: String, Content {
    case markdown, rawHtml
}

struct ScrapeMarkdownInput: Content {
    let url: String
    let formats: [FirecrawlFormats]
}

struct FirecrawlClient {
    func scrapeMarkdown(from: ScrapeMarkdownInput) async throws -> String {
        let baseUrl = try Environment.getOrThrow("FIRECRAWL_BASE_URL")

        guard let url = URL(string: "\(baseUrl)/v1/scrape") else {
            throw GenericErrors.invalidUrl
        }

        var request = URLRequest(url: url, timeoutInterval: Double.infinity)

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try from.encodeToData()

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 else {
            return ""
        }

        return data.base64EncodedString()
    }
}
