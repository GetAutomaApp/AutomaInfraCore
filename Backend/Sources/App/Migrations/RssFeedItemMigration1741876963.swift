// RssFeedItemMigration1741876963.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

struct RssFeedItemMigration1741876963: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("RSS-Feed-Item")
            .id()
            .field(
                "rss_feed_id",
                .uuid,
                .required,
                .references("RSS-Feed", "id")
            )
            .field("content", .string, .required)
            .field("link", .string, .required)
            .field("updated_at", .datetime)
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("Rss-Feed-Item").delete()
    }
}
