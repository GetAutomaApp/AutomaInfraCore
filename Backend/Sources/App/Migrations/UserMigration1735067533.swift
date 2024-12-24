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
            .field("username", .string, .required)
            .field("phone_number", .string, .required)
            .field("instagram_handle", .string)
            .field("updated_at", .datetime, .required)
            .field("created_at", .datetime, .required)
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
