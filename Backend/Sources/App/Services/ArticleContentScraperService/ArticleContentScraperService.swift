// ArticleContentScraperService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaUtilities
import Fluent
import SwiftSoup
import Vapor

internal struct ArticleContentScraperService {
    internal let client: any Client
    internal let logger: Logger

    public func getArticle(payload: AutomaWebCoreAPIEndpointPayload) async throws -> Article {
        let textContent = try await getWebsiteHTMLTextContent(payload)
        let response = try await ChatCompletionClient(logger: logger).createChat(
            .init(
                model: .gpt4omini,
                prompt: """
                I want to convert an article to this format:

                {
                    "name": "article name here",
                    "author": "article writer/author here",
                    "posted_at": "Date article was posted, don't provide 'posted_at' key if value not found",
                    "content_markdown": "**full article content as markdown here**, the full article, formatted and well-punctuated; not just a section of it"
                }

                Simply return **only a json code snippet without the snippet signs (```)** in the exact format shown above.

                Here is the text extracted from the article web page:
                \(textContent)
                """
            )
        ).message
        guard
            let articleDictData = response.data(using: .utf8)
        else {
            throw Abort(.internalServerError)
        }

        let article = try JSONDecoder().decode(Article.self, from: articleDictData)
        return article
    }

    private func getWebsiteHTMLTextContent(_ payload: AutomaWebCoreAPIEndpointPayload) async throws -> String {
        let websiteHTMLString = try await AutomaWebCoreClient(client: client)
            .getWebsiteHTML(payload: payload)
        let parsedWebsiteHTML = try SwiftSoup.parse(websiteHTMLString)
        let textContent = try parsedWebsiteHTML.text()
        return textContent
    }

    public struct Article: Content {
        let name: String
        let author: String
        let postedAt: Date?
        let contentMarkdown: String

        public init(from decoder: any Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            name = try values.decode(String.self, forKey: .name)
            author = try values.decode(String.self, forKey: .author)
            contentMarkdown = try values.decode(String.self, forKey: .contentMarkdown)
            postedAt = try? values.decode(Date.self, forKey: .postedAt)
        }

        private enum CodingKeys: String, CodingKey {
            case name
            case author
            case postedAt = "posted_at"
            case contentMarkdown = "content_markdown"
        }
    }
}
