// UserMigration1735067533.swift
// was created on 12/24/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import PostgresKit

struct UserMigration1735067533: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("User")
            .id()
            .field("username", .string)
            .field("phone_number", .string)
            .field("instagram_handle", .string, .required)
            .field("updated_at", .datetime)
            .field("created_at", .datetime)
            .field("deleted_at", .datetime)
            .unique(on: "username")
            .unique(on: "phone_number")
            .create()

        try await (database as! SQLDatabase)
            .create(index: "idx_user_by_username")
            .on("User")
            .column("username")
            .run()
    }

    func revert(on database: Database) async throws {
        try await database.schema("User").delete()
        try await (database as! SQLDatabase).drop(index: "idx_user_by_username").run()
    }
}
