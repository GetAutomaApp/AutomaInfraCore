// AddAcceptedColumnMigration1740658649.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

internal struct AddAcceptedColumnMigration1740658649: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("User")
            .field("accepted", .bool)
            .update()
    }

    public func revert(on _: Database) throws {}
}
