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

/// Configures the database for the application.
/// - Parameter app: The Vapor application instance.
/// - Throws: Throws an error if configuration fails.
public func configureDatabase(
    app: Application
) async throws {
    // Retrieve database URLs from the environment
    let primaryDatabaseURL = try Environment.getOrThrow("PRIMARY_POSTGRES_URL")
    let regionalDatabaseURL = try Environment.getOrThrow("REGIONAL_POSTGRES_URL")

    // Configure the primary and read-only databases
    try app.databases.use(.postgres(
        url: primaryDatabaseURL
    ), as: .primary)

    try app.databases.use(.postgres(
        url: regionalDatabaseURL
    ), as: .readOnly)

    // Add database migrations
    app.migrations.add(CreateUserStorageItem())
    app.migrations.add(UserMigration1735067533())
    app.migrations.add(AuthenticationCodeMigration1735069859())
    app.migrations.add(JwtTokenMigration1735121142())
    app.migrations.add(JWTTokenShouldBeBoundToParentUserObjectMigration1735140054())
    app.migrations.add(UserProfileAddProfilePictureMigration1735216565())
    app.migrations.add(UserProfileConvertIdToImageKeyMigration1735294202())
    app.migrations.add(JobMetadataMigrate())
    app.migrations.add(RemoveUserStorageMigration1739456565())
    app.migrations.add(AddAcceptedColumnMigration1740658649())
    app.migrations.add(TwitterOAuthTokenMigration1741687313())
    app.migrations.add(TwitterUserTokenMigration1741708919())

    // Perform automatic database migration
    try await app.autoMigrate()
}

/// Configures the application.
/// - Parameter app: The Vapor application instance.
/// - Throws: Throws an error if configuration fails.
public func configure(_ app: Application) async throws {
    // This is file middleware
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(ErrorStringMiddleware())

    // Determine the environment
    let environment = Environment.get("ENVIRONMENT") ?? "local"

    // Use async commands for non-local environments
    if environment != "local", environment != "testing" {
        app.asyncCommands.use(QueuesCommand(application: app), as: "vapor-queues")
    }

    // Retrieve database URLs from the environment
    let primaryDatabaseURL = Environment.get("PRIMARY_POSTGRES_URL")
    let regionalDatabaseURL = Environment.get("REGIONAL_POSTGRES_URL")

    // Check if database URLs are available
    let hasDatabaseUrls = primaryDatabaseURL != nil && regionalDatabaseURL != nil

    if hasDatabaseUrls {
        // Configure the database
        try await configureDatabase(
            app: app
        )

        // Register controllers
        try app.register(collection: AuthenticationController())
        try app.register(collection: AppLaunchController())
        try app.register(collection: TwitterController())
        try app.register(collection: ChatCompletionController())
        try app.register(collection: FirecrawlTestController())
        try app.register(collection: PrometheusController())

        // Configure JWT authentication
        guard
            let encryptionSecret = Environment.get("JWT_ENCRYPTION_SECRET")!
        else {
            logger.error(
                "Could not get JWT_ENCRYPTION_SECRET from environment.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                ]
            )
            throw Abort(.internalServerError)
        }
        await app.jwt.keys
            .add(hmac: .init(stringLiteral: encryptionSecret), digestAlgorithm: .sha256)

        // Configure queues
        app.queues.use(.fluent(useSoftDeletes: true))
        app.queues.configuration.workerCount = 1
        app.queues.configuration.refreshInterval = .seconds(5)

        // Add jobs to the queue
        app.queues.add(TransactionalMessageAsyncJob())
        app.queues.add(ProfilePictureAsyncJob())

        // Configure HTTP server
        app.http.server.configuration.responseCompression = .enabled
    }

    // keep this here while `AppTests.swift` is empty
}

/// Extension for `DatabaseID` to define custom database identifiers.
internal extension DatabaseID {
    /// Primary database identifier.
    static let primary = DatabaseID(string: "primary")
    /// Read-only database identifier.
    static let readOnly = DatabaseID(string: "readOnly")
}

/// Extension for `Request` to provide database access.
public extension Request {
    /// Provides write access to the database.
    var dbWrite: Database {
        db(.readOnly)
    }

    /// Provides read-only access to the database.
    var dbReadOnly: Database {
        db(.readOnly)
    }
}
