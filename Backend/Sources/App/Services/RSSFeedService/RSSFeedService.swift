// RSSFeedService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

struct RSSFeedService {
    let database: Database
    let rssFeedClient = RSSFeedReaderClient()
    let client: Client
    let logger: Logger

    func addFeedToUser(userId: UUID, feedUrl: URL) async throws -> Bool {
        do {
            if try await !rssFeedClient.read(from: feedUrl).isRssFeed {
                print("isn't rss feed")
                return false
            }

            let (feed, _) = try await createFeedInDBIfNotExist(feedUrl: feedUrl)
            try await addUserFeedMapping(feedId: feed.id, userId: userId)
            return true
        } catch {
            // TODO: Log error
            print("unknown error \(error.localizedDescription)")
            return false
        }
    }

    // If the model already exists we return true
    func createFeedInDBIfNotExist(feedUrl: URL) async throws -> (RSSFeedDTO, Bool) {
        let feedUrlString = feedUrl.absoluteString
        if let feed = try await RSSFeedModel.query(on: database).filter(\.$link == feedUrlString).first() {
            // The feed exists, so we just return it as a DTO
            return try (feed.toDTO(), true)
        }

        // Create the new feed model
        let feed = RSSFeedModel(
            id: UUID(),
            link: feedUrlString
        )

        // Save the newly created feed
        try await feed.save(on: database)

        // Now that the feed is saved, return the DTO
        return try (feed.toDTO(), false)
    }

    // TODO: Discardable feed mapping id return
    @discardableResult
    func addUserFeedMapping(feedId: UUID, userId: UUID) async throws -> UserFeedMappingDTO {
        if let existingMapping = try await UserFeedMappingModel.query(on: database).filter(\.$userId == userId)
            .filter(\.$feedId == feedId).first()
        {
            return existingMapping.toDTO()
        }

        let newMapping = UserFeedMappingModel(userId: userId, feedId: feedId)

        try await newMapping.save(on: database)

        return newMapping.toDTO()
    }

    func scrapeAndInsertLatestForAllFeeds() async throws {
        let feeds = try await RSSFeedModel.query(on: database).all()

        for feed in feeds {
            do {
                try await scrapeAndInsertLatestRSSFeedItems(feedDTO: feed.toDTO())
            } catch {
                // Fix log
                logger.error("Failed to process feed \(feed.link): \(error.localizedDescription)")
            }
        }
    }

    func scrapeAndInsertLatestRSSFeedItems(feedDTO: RSSFeedDTO) async throws {
        let firecrawlClient = try FirecrawlClient(client: client, logger: logger)

        let url = URL(string: feedDTO.link.absoluteString)

        guard let url else {
            return
        }

        let latestFeedItems = try await rssFeedClient.read(from: url).items
        let latestFeedItemLinks = latestFeedItems.map(\.link)

        let existingFeedItems = try await RSSFeedItemModel.query(on: database)
            .filter(\.$link ~~ latestFeedItemLinks)
            .all()

        let existingFeedItemLinks = Set(existingFeedItems.map(\.link))

        let unprocessedLinks = Set(latestFeedItemLinks).subtracting(existingFeedItemLinks)

        var feedItems: [RssFeedItemDTO] = []

        for link in unprocessedLinks {
            do {
                let content = try await firecrawlClient.scrapeMarkdown(
                    from: .init(url: link)
                )

                let article = RSSFeedItemModel(
                    rssFeedId: feedDTO.id,
                    content: content.markdown,
                    link: link
                )

                try await article.save(on: database)

                feedItems.append(article.toDTO())
            } catch {
                // Log the error if scraping fails
                logger.error("Failed to scrape content for link \(link): \(error.localizedDescription)")
            }
        }

        // TODO: Log feedItems if necessary
    }
}
