// FirecrawlClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

enum FirecrawlFormats: String, Content {
    case markdown, rawHtml
}

struct ScrapeMarkdownInput: Content {
    let url: String
    let timeout: Int = 60000
}

struct FirecrawlDataResult: Content {
    let markdown: String
    let links: [String]
}

struct FirecrawlScrapeResult: Content {
    let success: Bool
    let data: FirecrawlDataResult
}

struct WebsiteResponseItem: Content {
    let links: [String]
    let markdown: String
    let imageUrls: [String]
}
