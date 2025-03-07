// RSSFeedTypesDTO.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public struct GenericRSSFeedItem: Content {
    public let title: String
    public let link: String
    public let description: String
    public let publishDate: Date

    public init(title: String, link: String, description: String, publishDate: Date) {
        self.title = title
        self.link = link
        self.description = description
        self.publishDate = publishDate
    }
}

public struct RssFeedResponse: Content {
    public let items: [GenericRSSFeedItem]
    public let isRssFeed: Bool

    public init(items: [GenericRSSFeedItem], isRssFeed: Bool) {
        self.items = items
        self.isRssFeed = isRssFeed
    }
}
