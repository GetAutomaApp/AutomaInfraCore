// JwtTokenMigration1735121142.swift
// was created on 12/24/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

struct JwtTokenMigration1735121142: AsyncMigration {
    func prepare(on database: Database) async throws {
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

    func revert(on database: Database) async throws {
        try await database.schema("Jwt-Token").delete()
    }
}
