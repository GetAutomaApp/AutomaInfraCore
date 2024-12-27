// UserProfileConvertIdToImageKeyMigration1735294202.swift
// was created on 12/27/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

struct UserProfileConvertIdToImageKeyMigration1735294202: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("User")
            .deleteField("profile_picture_id")
            .field("profile_picture_key", .string)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema("User")
            .field("profile_picture_id", .uuid)
            .update()
    }
}
