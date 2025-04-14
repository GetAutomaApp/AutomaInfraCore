// AddAcceptedColumnMigration1740658649.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

struct AddAcceptedColumnMigration1740658649: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("User")
            .field("accepted", .bool)
            .update()
    }

    func revert(on _: Database) throws {}
}
