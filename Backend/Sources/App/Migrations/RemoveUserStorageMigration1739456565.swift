// RemoveUserStorageMigration1739456565.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

internal struct RemoveUserStorageMigration1739456565: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("user-storage").delete()
    }

    public func revert(on _: any FluentKit.Database) throws {}
}
