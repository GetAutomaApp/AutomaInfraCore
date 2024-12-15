// configure.swift
// was created on 10/22/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import FluentPostgresDriver
import Vapor

// Configures your application
public func configure(_ app: Application) async throws {
    // Middleware for serving files (if needed)
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.commands.use(GenerateAppComponent(), as: "generate")
    app.commands.use(FlyConfigGenerator(), as: "fly-config")

    guard let primaryDatabaseURL = Environment.get("PRIMARY_POSTGRES_URL"),
          let regionalDatabaseURL = Environment.get("REGIONAL_POSTGRES_URL")
    else {
        throw Abort(.notFound, reason: "Primary or Regional Postgres URL not found")
    }

    print(primaryDatabaseURL, regionalDatabaseURL)

    try app.databases.use(.postgres(
        url: primaryDatabaseURL
    ), as: .primary)

    try app.databases.use(.postgres(
        url: regionalDatabaseURL
    ), as: .readOnly)

    app.migrations.add(CreateUserStorageItem())

    try await app.autoMigrate()

    try app.register(collection: UserStorageController())
    try routes(app)
}

// Extend DatabaseID to define custom database identifiers
extension DatabaseID {
    static let primary = DatabaseID(string: "primary") // Write DB
    static let readOnly = DatabaseID(string: "readOnly") // Read-only DB
}

extension Request {
    var dbWrite: Database {
        db(.primary)
    }

    var dbReadOnly: Database {
        db(.readOnly)
    }
}
