// FirecrawlClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

enum FirecrawlFormats: String, Content {
    case markdown, rawHtml
}

internal struct ScrapeMarkdownInput: Content {
    let url: String
}

internal struct FirecrawlDataResult: Content {
    let markdown: String
    let links: [String]
}

internal struct FirecrawlScrapeResult: Content {
    let success: Bool
    let data: FirecrawlDataResult
}

internal struct WebsiteResponseItem: Content {
    let links: [String]
    let markdown: String
    let imageUrls: [String]
}
