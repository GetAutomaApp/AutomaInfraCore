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
        try await convertWebsiteHTMLTextContentToArticle(getWebsiteHTMLTextContent(payload))
    }

    private func convertWebsiteHTMLTextContentToArticle(_ textContent: String) async throws -> Article {
        let jsonString = try await convertWebsiteHTMLTextContentToJSON(textContent)
        let jsonData = try websiteContentJSONStringToData(jsonString)
        let article = try JSONDecoder().decode(Article.self, from: jsonData)
        return article
    }

    private func getWebsiteHTMLTextContent(_ payload: AutomaWebCoreAPIEndpointPayload) async throws -> String {
        let websiteHTMLString = try await AutomaWebCoreClient(client: client)
            .getWebsiteHTML(payload: payload)
        let parsedWebsiteHTML = try SwiftSoup.parse(websiteHTMLString)
        let textContent = try parsedWebsiteHTML.text()
        return textContent
    }

    private func convertWebsiteHTMLTextContentToJSON(_ textContent: String) async throws -> String {
        let response = try await ChatCompletionClient(logger: logger).createChat(
            .init(
                model: .gpt4omini,
                prompt: getConvertHTMLToJSONChatCompletionPrompt(textContent: textContent)
            )
        ).message
        return response
    }

    private func getConvertHTMLToJSONChatCompletionPrompt(textContent: String) -> String {
        """
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
    }

    private func websiteContentJSONStringToData(_ jsonString: String) throws -> Data {
        guard
            let data = jsonString.data(using: .utf8)
        else {
            throw Abort(.internalServerError)
        }
        return data
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
