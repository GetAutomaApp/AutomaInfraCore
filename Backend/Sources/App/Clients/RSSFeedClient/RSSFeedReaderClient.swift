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
    let logger: Logger

    func read(from url: URL) async throws -> RssFeedResponse {
        BackendMetric.rssFeedReadCall(status: .start, url: url).increment()

        var feed: Feed?
        let maxAttempts = 3

        do {
            try await retry(
                maxAttempts: maxAttempts
            ) {
                feed = try await Feed(url: url)
            }
        } catch {
            logger.error(
                "Failed to convert '\(url)' to Feed after \(maxAttempts) attempts.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(String(reflecting: error)),
                ]
            )

            BackendMetric.rssFeedReadCall(
                status: .fail,
                url: url,
                isRssFeed: false,
                didThrowOnFeedInitialization: true
            ).increment()

            return .init(items: [], isRssFeed: false)
        }

        let isRssFeed: Bool
        let response: RssFeedResponse

        switch feed {
        case let .rss(rSSFeed):
            isRssFeed = true
            let items = convertRSSToGenericFeedItems(items: rSSFeed.channel?.items ?? [])
            response = .init(items: items, isRssFeed: isRssFeed)
        case let .atom(atomFeed):
            isRssFeed = true
            let items = convertAtomToGenericFeedItems(entries: atomFeed.entries ?? [])
            response = .init(items: items, isRssFeed: isRssFeed)
        default:
            isRssFeed = false
            response = .init(items: [], isRssFeed: isRssFeed)
        }

        BackendMetric.rssFeedReadCall(status: .success, url: url, isRssFeed: isRssFeed).increment()

        return response
    }

    private func convertRSSToGenericFeedItems(items feedItems: [RSSFeedItem]) -> [GenericRSSFeedItem] {
        let items = feedItems.compactMap { feedItem -> GenericRSSFeedItem? in
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
                links: [link],
                description: description,
                publishDate: publishDate
            )
        }

        return items
    }

    private func convertAtomToGenericFeedItems(entries feedEntries: [AtomFeedEntry]) -> [GenericRSSFeedItem] {
        let entries = feedEntries.compactMap { entry -> GenericRSSFeedItem? in
            guard
                let title = entry.title,
                let links = entry.links?.compactMap({ $0.attributes?.href }),
                let summary = entry.summary?.text,
                let publishDate = entry.published
            else {
                return nil
            }

            var youtube: GenericRSSFeedItemYoutube?
            if
                let youtubeEntry = entry.youTube,
                let channelID = youtubeEntry.channelID,
                let videoID = youtubeEntry.videoID
            {
                youtube = .init(channelID: channelID, videoID: videoID)
            }

            return GenericRSSFeedItem(
                title: title,
                links: links,
                description: summary,
                publishDate: publishDate,
                content: entry.content?.text,
                youtube: youtube
            )
        }
        return entries
    }
}
