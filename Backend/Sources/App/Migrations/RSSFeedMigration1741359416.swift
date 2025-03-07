// RSSFeedMigration1741359416.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

struct RSSFeedMigration1741359416: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("RSS-Feed")
            .id()
            .field("link", .string)
            .field("updated_at", .datetime)
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("RSS-Feed").delete()
    }
}
