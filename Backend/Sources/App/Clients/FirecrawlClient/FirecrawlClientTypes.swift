// FirecrawlClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

internal enum FirecrawlFormats: String, Content {
    case markdown, rawHtml
}

internal struct ScrapeMarkdownInput: Content {
    public let url: String
}

internal struct FirecrawlDataResult: Content {
    public let markdown: String
    public let links: [String]
}

internal struct FirecrawlScrapeResult: Content {
    public let success: Bool
    public let data: FirecrawlDataResult
}

internal struct WebsiteResponseItem: Content {
    public let links: [String]
    public let markdown: String
    public let imageUrls: [String]
}
