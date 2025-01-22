// CreateUserStorageItem.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

struct CreateUserStorageItem: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("user-storage")
            .id()
            .field("key", .string, .required)
            .field("value", .string, .required)
            .field("userId", .uuid)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("user-storage").delete()
    }
}
