// JWTTokenShouldBeBoundToParentUserObjectMigration1735140054.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

struct JWTTokenShouldBeBoundToParentUserObjectMigration1735140054: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("Jwt-Token")
            .foreignKey("user_id", references: "User", "id", onDelete: .cascade)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema("Jwt-Token")
            .deleteForeignKey(name: "user_id")
            .update()
    }
}
