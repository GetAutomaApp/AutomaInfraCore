// UserMigration1735067533.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import PostgresKit

/// Migration to create the User schema.
internal struct UserMigration1735067533: AsyncMigration {
    /// Prepares the migration by creating the User schema.
    /// - Parameter database: The database instance on which the migration is performed.
    /// - Throws: Throws an error if the schema creation fails.
    public func prepare(on database: Database) async throws {
        try await database.schema("User")
            .id() // Add an ID field
            .field("username", .string, .required) // Add a required username field
            .field("phone_number", .string, .required) // Add a required phone_number field
            .field("instagram_handle", .string) // Add an optional instagram_handle field
            .field("updated_at", .datetime, .required) // Add a required updated_at timestamp field
            .field("created_at", .datetime, .required) // Add a required created_at timestamp field
            .field("deleted_at", .datetime) // Add a deleted_at timestamp field
            .unique(on: "username") // Ensure username is unique
            .unique(on: "phone_number") // Ensure phone_number is unique
            .create() // Create the schema

        // Create an index on the username column
        try await (database as! SQLDatabase)
            .create(index: "idx_user_by_username")
            .on("User")
            .column("username")
            .run()
    }

    /// Reverts the migration by deleting the User schema and its index.
    /// - Parameter database: The database instance on which the migration is reverted.
    /// - Throws: Throws an error if the schema deletion fails.
    public func revert(on database: Database) async throws {
        try await database.schema("User").delete()
        try await (database as! SQLDatabase).drop(index: "idx_user_by_username").run()
    }
}
