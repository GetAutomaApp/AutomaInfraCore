// UserFeedMappingMigration1741429746.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

struct UserFeedMappingMigration1741429746: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("User-Feed-Mapping")
            .id()
            .field("feed_id", .uuid, .required, .references("RSS-Feed", "id"))
            .field("user_id", .uuid, .required, .references("User", "id"))
            .field("updated_at", .datetime)
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("User-Feed-Mapping").delete()
    }
}
