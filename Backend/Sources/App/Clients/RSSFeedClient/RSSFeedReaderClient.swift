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

/// A client for reading and parsing RSS and Atom feeds from URLs.
/// This client handles fetching feed data, parsing it into appropriate formats,
/// and converting feed items into a standardized `GenericRSSFeedItem` format.
struct RSSFeedReaderClient {
    /// Logger instance used for error reporting and debugging.
    let logger: Logger

    /// Reads and parses a feed from the specified URL.
    /// - Parameter url: The URL of the RSS or Atom feed to read.
    /// - Returns: A `RssFeedResponse` containing parsed feed items and metadata.
    /// - Throws: Any errors encountered during the feed fetching or parsing process.
    func read(from url: URL) async throws -> RssFeedResponse {
        BackendMetric.rssFeedReaderMetric(status: .start, url: url).increment()

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
                "Failed to convert '\(url)' to feed after \(maxAttempts) attempts.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(String(reflecting: error)),
                ]
            )

            BackendMetric.rssFeedReaderMetric(
                status: .fail,
                url: url,
                isRSSFeed: false,
                didThrowOnFeedInitialization: true
            ).increment()

            throw RSSFeedReaderClientError.failedToReadFeed(error)
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

        BackendMetric.rssFeedReaderMetric(status: .success, url: url, isRSSFeed: isRssFeed).increment()

        return response
    }

    /// Converts RSS feed items to the generic feed item format.
    /// - Parameter feedItems: An array of RSS feed items to convert.
    /// - Returns: An array of converted `GenericRSSFeedItem` objects.
    private func convertRSSToGenericFeedItems(items feedItems: [RSSFeedItem]) -> [GenericRSSFeedItem] {
        feedItems.compactMap { feedItem -> GenericRSSFeedItem? in
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
    }

    /// Converts Atom feed entries to the generic feed item format.
    /// - Parameter feedEntries: An array of Atom feed entries to convert.
    /// - Returns: An array of converted `GenericRSSFeedItem` objects.
    private func convertAtomToGenericFeedItems(entries feedEntries: [AtomFeedEntry]) -> [GenericRSSFeedItem] {
        feedEntries.compactMap { entry -> GenericRSSFeedItem? in
            guard
                let title = entry.title,
                let links = entry.links?.compactMap({ $0.attributes?.href }),
                let summary = entry.summary?.text,
                let publishDate = entry.published
            else {
                return nil
            }

            var youTubeVideoInfo: RSSFeedItemYouTubeVideoInfo?
            if
                let youtubeEntry = entry.youTube,
                let channelID = youtubeEntry.channelID,
                let videoID = youtubeEntry.videoID
            {
                youTubeVideoInfo = .init(channelID: channelID, videoID: videoID)
            }

            return GenericRSSFeedItem(
                title: title,
                links: links,
                description: summary,
                publishDate: publishDate,
                content: entry.content?.text,
                youTubeVideoInfo: youTubeVideoInfo
            )
        }
    }
}
