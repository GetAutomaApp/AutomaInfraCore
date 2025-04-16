// RSSFeedTypesDTO.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

/// A standardized representation of an RSS or Atom feed item.
/// This struct normalizes the different formats into a common structure
/// that can be used throughout the application.
public struct GenericRSSFeedItem: Content {
    /// The title of the feed item.
    public let title: String

    /// URLs associated with this feed item, typically including the permalink.
    public let links: [String]

    /// A summary or brief description of the feed item content.
    public let description: String

    /// The date when the feed item was published.
    public let publishDate: Date

    /// The full content of the feed item, if available.
    public let content: String?

    /// YouTube-specific metadata, if this feed item represents a YouTube video.
    public let youTubeVideoInfo: RSSFeedItemYouTubeVideoInfo?

    /// Creates a new generic RSS feed item.
    /// - Parameters:
    ///   - title: The title of the feed item.
    ///   - links: URLs associated with this feed item.
    ///   - description: A summary or brief description of the feed item.
    ///   - publishDate: The date when the feed item was published.
    ///   - content: The full content of the feed item, if available.
    ///   - youTubeVideoInfo: YouTube-specific metadata, if applicable.
    public init(
        title: String,
        links: [String],
        description: String,
        publishDate: Date,
        content: String? = nil,
        youTubeVideoInfo: RSSFeedItemYouTubeVideoInfo? = nil
    ) {
        self.title = title
        self.links = links
        self.description = description
        self.publishDate = publishDate
        self.content = content
        self.youTubeVideoInfo = youTubeVideoInfo
    }
}

/// Response structure containing parsed feed items and metadata.
public struct RssFeedResponse: Content {
    /// The collection of parsed feed items.
    public let items: [GenericRSSFeedItem]

    /// Indicates whether the source was a valid RSS or Atom feed.
    public let isRssFeed: Bool

    /// Creates a new RSS feed response.
    /// - Parameters:
    ///   - items: The collection of parsed feed items.
    ///   - isRssFeed: Indicates whether the source was a valid RSS or Atom feed.
    public init(items: [GenericRSSFeedItem], isRssFeed: Bool) {
        self.items = items
        self.isRssFeed = isRssFeed
    }
}

/// Contains YouTube-specific metadata for feed items that represent YouTube videos.
public struct RSSFeedItemYouTubeVideoInfo: Content {
    /// The YouTube channel identifier.
    public let channelID: String

    /// The YouTube video identifier.
    public let videoID: String

    /// Creates a new YouTube video info object.
    /// - Parameters:
    ///   - channelID: The YouTube channel identifier.
    ///   - videoID: The YouTube video identifier.
    public init(channelID: String, videoID: String) {
        self.channelID = channelID
        self.videoID = videoID
    }
}
