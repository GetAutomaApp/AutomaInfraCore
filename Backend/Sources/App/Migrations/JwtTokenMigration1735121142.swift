// JwtTokenMigration1735121142.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

internal struct JwtTokenMigration1735121142: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("Jwt-Token")
            .id()
            .field("token", .string, .required)
            .field("user_id", .uuid, .required)
            .field("subject", .string, .required)
            .field("updated_at", .datetime)
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    public func revert(on database: Database) async throws {
        try await database.schema("Jwt-Token").delete()
    }
}
