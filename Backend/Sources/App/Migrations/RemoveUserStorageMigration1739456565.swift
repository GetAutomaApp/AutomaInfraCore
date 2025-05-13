// RemoveUserStorageMigration1739456565.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

/// Migration to remove the user-storage schema.
struct RemoveUserStorageMigration1739456565: AsyncMigration {
    /// Prepares the migration by deleting the user-storage schema.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema deletion fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("user-storage").delete()
    }

    /// Reverts the migration. No action is taken as the schema is deleted.
    /// - Parameter database: The database instance on which the migration is reverted.
    /// - Throws: Throws an error if the schema update fails.
    public func revert(on _: any FluentKit.Database) throws {}
}
