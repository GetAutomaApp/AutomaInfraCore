// configure.swift
// was created on 10/22/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import FluentPostgresDriver
import JWT
import Vapor

// Configures your application
public func configure(_ app: Application) async throws {
    // Middleware for serving files (if needed)
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.commands.use(GenerateAppComponent(), as: "generate")
    app.commands.use(FlyConfigGenerator(), as: "fly-config")

    let primaryDatabaseURL = Environment.get("PRIMARY_POSTGRES_URL")

    let regionalDatabaseURL = Environment.get("REGIONAL_POSTGRES_URL")

    let hasDatabaseUrls = primaryDatabaseURL != nil && regionalDatabaseURL != nil

    if hasDatabaseUrls {
        try app.databases.use(.postgres(
            url: primaryDatabaseURL!
        ), as: .primary)

        try app.databases.use(.postgres(
            url: regionalDatabaseURL!
        ), as: .readOnly)

        app.migrations.add(CreateUserStorageItem())
        app.migrations.add(UserMigration1735067533())
        app.migrations.add(AuthenticationCodeMigration1735069859())
        app.migrations.add(JwtTokenMigration1735121142())
        app.migrations.add(JWTTokenShouldBeBoundToParentUserObjectMigration1735140054())

        try await app.autoMigrate()

        try app.register(collection: UserStorageController())
        try app.register(collection: AuthenticationController())

        await app.jwt.keys
            .add(hmac: .init(stringLiteral: Environment.get("JWT_ENCRYPTION_SECRET")!), digestAlgorithm: .sha256)
    }
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
