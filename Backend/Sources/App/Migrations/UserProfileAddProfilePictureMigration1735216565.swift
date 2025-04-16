// UserProfileAddProfilePictureMigration1735216565.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

internal struct UserProfileAddProfilePictureMigration1735216565: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("User")
            .field("profile_picture_id", .uuid)
            .update()
    }

    public func revert(on database: Database) async throws {
        try await database.schema("User")
            .deleteField("profile_picture_id")
            .update()
    }
}
