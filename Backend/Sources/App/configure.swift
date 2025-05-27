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


public func configure(_ app: Application) async throws {
    try await AppConfigurator(app: app).configure()
}

internal struct AppConfigurator {
    let app: Application
    private let environment = Environment.get("ENVIRONMENT") ?? "local"
    private let primaryDatabaseURL: String? = try? DatabaseURLs.primary.get()
    private let regionalDatabaseURL: String? = try? DatabaseURLs.regional.get()

    public func configure() async throws {
        registerMiddleware()
        registerQueues()
        let hasDatabaseURLs = (primaryDatabaseURL != nil) || (regionalDatabaseURL != nil)
        if hasDatabaseURLs {
            try await configureWhenDatabaseURLsAvailable()
        }
    }

    private func registerMiddleware() {
        app.middleware.use(ErrorStringMiddleware())
    }

    private func registerQueues() {
        if ["local", "testing"].contains(environment) == false {
            app.asyncCommands.use(QueuesCommand(application: app), as: "vapor-queues")
        }
    }

    private func configureWhenDatabaseURLsAvailable() async throws {
        try await DatabaseConfigurator(app: app).configureDatabases()
        try registerControllers()
        try await addAuthenticationJWTKey()
        configureQueues()
        addJobsToQueue()
        configureServer()
    }

    private func registerControllers() throws {
        try app.register(collection: AuthenticationController())
        try app.register(collection: AppLaunchController())
        try app.register(collection: TwitterController())
        try app.register(collection: ChatCompletionController())
        try app.register(collection: FirecrawlTestController())
        try app.register(collection: PrometheusController())
    }

    private func addAuthenticationJWTKey() async throws {
        let encryptionSecret = try Environment.getOrThrow("JWT_ENCRYPTION_SECRET")
        await app.jwt.keys.add(hmac: .init(stringLiteral: encryptionSecret), digestAlgorithm: .sha256)
    }

    private func configureQueues() {
        app.queues.use(.fluent(useSoftDeletes: true))
        app.queues.configuration.workerCount = 1
        app.queues.configuration.refreshInterval = .seconds(5)
    }

    private func addJobsToQueue() {
        app.queues.add(TransactionalMessageAsyncJob())
        app.queues.add(ProfilePictureAsyncJob())
    }

    private func configureServer() {
        app.http.server.configuration.responseCompression = .enabled
    }
}

public struct DatabaseConfigurator {
    let app: Application

    public func configureDatabases() async throws {
        try registerDatabases()
        addMigrations()
        try await app.autoMigrate()
    }

    private func registerDatabases() throws {
        try app.databases.use(.postgres(
            url: DatabaseURLs.primary.get()
        ), as: .primary)

        try app.databases.use(.postgres(
            url: DatabaseURLs.regional.get()
        ), as: .readOnly)
    }

    private func addMigrations() {
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
    }
}

internal enum DatabaseURLs {
    static let primary: Result<String, Error> = Result { try Environment.getOrThrow("PRIMARY_POSTGRES_URL") }
    static let regional: Result<String, Error> = Result { try Environment.getOrThrow("REGIONAL_POSTGRES_URL") }
}
