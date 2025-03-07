// RSSFeedService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

struct RSSFeedService {
    let database: Database

    func addFeedToUser(userId _: UUID, feedUrl _: URL) async throws {}

    // If the model already exists we return true
    func createFeedIfNotExist(feedUrl: URL) async throws -> (RSSFeedDTO, Bool) {
        if let feed = try await RSSFeedModel.query(on: database).filter(\.$link == feedUrl).first() {
            return (feed.toDTO(), true)
        }

        let feed = RSSFeedModel(
            id: UUID(),
            link: feedUrl
        )

        try await feed.save(on: database)

        return (feed.toDTO(), false)
    }

    // TODO: Discardable feed mapping id return
    func addUserFeedMapping(feedId _: UUID, userId _: UUID) {}

    // Scrape Feed Posts + Add to table
    // Scrape Feed Content + Add to table
}
