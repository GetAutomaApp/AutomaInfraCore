// FirecrawlClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

/// An enumeration representing the formats supported by the FirecrawlClient.
///
/// This enum defines the content formats that can be scraped by the FirecrawlClient,
/// including markdown and raw HTML.
internal enum FirecrawlFormats: String, Content {
    /// Represents content in markdown format.
    case markdown

    /// Represents content in raw HTML format.
    case rawHtml
}

/// A structure representing the input required for scraping markdown content.
///
/// This struct is used to encapsulate the URL from which markdown content will be scraped.
internal struct ScrapeMarkdownInput: Content {
    /// The URL of the website to scrape.
    public let url: String
}

/// A structure representing the result of a data scrape operation.
///
/// This struct contains the scraped markdown content and any links found within it.
internal struct FirecrawlDataResult: Content {
    /// The markdown content scraped from the website.
    public let markdown: String

    /// The list of links extracted from the markdown content.
    public let links: [String]
}

/// A structure representing the result of a scrape operation.
///
/// This struct contains the success status of the operation and the data result.
internal struct FirecrawlScrapeResult: Content {
    /// Indicates whether the scrape operation was successful.
    public let success: Bool

    /// The data result containing markdown and links.
    public let data: FirecrawlDataResult
}

/// A structure representing the response item from a website scrape.
///
/// This struct contains the links, markdown content, and image URLs extracted from the website.
internal struct WebsiteResponseItem: Content {
    /// The list of links extracted from the website.
    public let links: [String]

    /// The markdown content extracted from the website.
    public let markdown: String

    /// The list of image URLs extracted from the markdown content.
    public let imageUrls: [String]
}
