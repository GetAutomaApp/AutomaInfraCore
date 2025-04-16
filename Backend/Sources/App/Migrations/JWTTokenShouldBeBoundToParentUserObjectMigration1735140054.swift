// JWTTokenShouldBeBoundToParentUserObjectMigration1735140054.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

internal struct JWTTokenShouldBeBoundToParentUserObjectMigration1735140054: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("Jwt-Token")
            .foreignKey("user_id", references: "User", "id", onDelete: .cascade)
            .update()
    }

    public func revert(on database: Database) async throws {
        try await database.schema("Jwt-Token")
            .deleteForeignKey(name: "user_id")
            .update()
    }
}
