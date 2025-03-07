// RSSFeedReaderClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import FeedKit
import Fluent
import Foundation
import Retry
import Vapor

struct RSSFeedReaderClient {
    func read(from url: URL) async -> RssFeedResponse {
        var feed: Feed? = nil

        do {
            try await retry(
                maxAttempts: 3
            ) {
                feed = try! await Feed(url: url)
            }
        } catch {}

        switch feed {
        case let .rss(rSSFeed):
            let items = convertRSSToGenericFeedItems(from: rSSFeed.channel?.items ?? [])
            return .init(items: items, isRssFeed: true)
        default:
            return .init(items: [], isRssFeed: false)
        }
    }

    func convertRSSToGenericFeedItems(from feedItems: [RSSFeedItem]) -> [GenericRSSFeedItem] {
        let items = feedItems.compactMap { feedItem -> GenericFeedItem? in
            guard
                let title = feedItem.title,
                let link = feedItem.link,
                let description = feedItem.description,
                let publishDate = feedItem.pubDate
            else {
                return nil
            }

            return GenericRSSFeedItem(
                title: title,
                link: link,
                description: description,
                publishDate: publishDate
            )
        }

        return items
    }
}
