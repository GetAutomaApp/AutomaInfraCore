// configure.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import FluentPostgresDriver
import JWT
import Queues
import QueuesFluentDriver
import Vapor

// Configures your application
public func configure(_ app: Application) async throws {
    // This is file middleware
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(ErrorStringMiddleware())

    app.commands.use(GenerateAppComponent(), as: "generate")
    app.commands.use(FlyConfigGenerator(), as: "fly-config")
    app.asyncCommands.use(QueuesCommand(application: app), as: "vapor-queues")

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

        // Migrations
        app.migrations.add(CreateUserStorageItem())
        app.migrations.add(UserMigration1735067533())
        app.migrations.add(AuthenticationCodeMigration1735069859())
        app.migrations.add(JwtTokenMigration1735121142())
        app.migrations.add(JWTTokenShouldBeBoundToParentUserObjectMigration1735140054())
        app.migrations.add(UserProfileAddProfilePictureMigration1735216565())
        app.migrations.add(UserProfileConvertIdToImageKeyMigration1735294202())
        app.migrations.add(JobMetadataMigrate())

        try await app.autoMigrate()

        // Controllers
        try app.register(collection: UserStorageController())
        try app.register(collection: AuthenticationController())

        // Authentication
        await app.jwt.keys
            .add(hmac: .init(stringLiteral: Environment.get("JWT_ENCRYPTION_SECRET")!), digestAlgorithm: .sha256)

        // Queues
        // Future: get prometheus metrics to be submitted to prom & not scraped!
        // We would like to run this in a separate process on a seperate fly app
        app.queues.use(.fluent(useSoftDeletes: true))
        app.queues.configuration.workerCount = 1

        // Jobs
        app.queues.add(TransactionalMessageAsyncJob())

        // Schedules
    }
}

public func configureMetrics(_ app: Application) async throws {
    try app.register(collection: PrometheusController())
}

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
