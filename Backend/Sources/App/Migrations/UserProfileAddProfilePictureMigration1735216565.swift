// UserProfileAddProfilePictureMigration1735216565.swift
// was created on 12/26/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

struct UserProfileAddProfilePictureMigration1735216565: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("User")
            .field("profile_picture_id", .uuid)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema("User")
            .deleteField("profile_picture_id")
            .update()
    }
}
