// RSSFeedService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import FeedKit
import Fluent
import Foundation
import Vapor

struct GenericFeedItem {
    let title: String
    let link: String
    let description: String
    let publishDate: Date
}

struct RSSFeedService {
    func read<T: FeedInitializable>(from _: URL, type _: T) async -> T {}

    func convertRSSToGenericFeedItems(from feedItems: [RSSFeedItem]) -> [GenericFeedItem] {
        let items = feedItems.compactMap { feedItem -> GenericFeedItem? in
            guard
                let title = feedItem.title,
                let link = feedItem.link,
                let description = feedItem.description,
                let publishDate = feedItem.pubDate
            else {
                return nil
            }

            return GenericFeedItem(
                title: title,
                link: link,
                description: description,
                publishDate: publishDate
            )
        }

        return items
    }

    func convertAtomToGenericFeedItems(from feedItems: [AtomFeedEntry]) -> [GenericFeedItem] {
        let items = feedItems.compactMap { feedItem -> GenericFeedItem? in
            guard
                let title = feedItem.title,
                let link = feedItem
        }
    }
}
