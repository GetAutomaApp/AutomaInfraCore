// RSSFeedService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

struct RSSFeedService {
    let database: Database

    func addFeedToUser(userId: UUID, feedUrl: URL) async throws -> Bool {
        do {
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

    // Scrape Feed Posts + Add to table
    func scrapeRSSFeedPosts(feedId _: UUID) async throws {
        let
    }
    // Scrape Feed Content + Add to table
}
