// AuthenticationCodeMigration1735069859.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

internal struct AuthenticationCodeMigration1735069859: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("Authentication-Code")
            .id()
            .field("phone_number", .string, .required)
            .field("code", .string, .required)
            .field("updated_at", .datetime)
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    public func revert(on database: Database) async throws {
        try await database.schema("Authentication-Code").delete()
    }
}
