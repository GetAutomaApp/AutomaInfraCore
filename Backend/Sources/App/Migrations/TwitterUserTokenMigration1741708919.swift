// TwitterUserTokenMigration1741708919.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

internal struct TwitterUserTokenMigration1741708919: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("Twitter-User-Token")
            .id()
            .field("updated_at", .datetime, .required)
            .field("created_at", .datetime, .required)
            .field("deleted_at", .datetime)
            .field("access_token", .string, .required)
            .field("secret_access_token", .string, .required)
            .field("oauth_verifier", .string, .required)
            .field("oauth_token_id", .uuid, .references("Twitter-O-Auth-Token", "id", onDelete: .cascade))
            .create()
    }

    public func revert(on database: Database) async throws {
        try await database.schema("Twitter-User-Token").delete()
    }
}
