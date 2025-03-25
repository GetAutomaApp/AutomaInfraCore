// RSSFeedTypesDTO.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public struct GenericRSSFeedItem: Content {
    public let title: String
    public let links: [String]
    public let description: String
    public let publishDate: Date
    public let content: String?
    public let youtube: GenericRSSFeedItemYoutube?

    public init(
        title: String,
        links: [String],
        description: String,
        publishDate: Date,
        content: String? = nil,
        youtube: GenericRSSFeedItemYoutube? = nil
    ) {
        self.title = title
        self.links = links
        self.description = description
        self.publishDate = publishDate
        self.content = content
        self.youtube = youtube
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

public struct GenericRSSFeedItemYoutube: Content {
    let channelID: String
    let videoID: String

    public init(channelID: String, videoID: String) {
        self.channelID = channelID
        self.videoID = videoID
    }
}
