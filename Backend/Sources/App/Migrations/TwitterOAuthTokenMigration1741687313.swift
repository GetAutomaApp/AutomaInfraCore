// TwitterOAuthTokenMigration1741687313.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

struct TwitterOAuthTokenMigration1741687313: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("Twitter-O-Auth-Token")
            .id()
            .field("updated_at", .datetime)
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .field("token", .string, .required)
            .field("user_id", .uuid, .references("User", "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("Twitter-O-Auth-Token").delete()
    }
}
