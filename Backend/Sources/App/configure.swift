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

struct AppConfigurator {
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
        try await DatabaseSeeder(app: app).seed()
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

/// Seed database with necessary data to run tests
public struct DatabaseSeeder {
    /// The main application
    public let app: Application

    /// Seed database
    public func seed() async throws {
        app.logger.info(
            "Seeding database.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)")
            ]
        )
        try await seedTwitterTokens()
    }

    /// Seed a single `TwitterUserToken` `TwitterOAuthToken` so that the post tweet tests have tokens of an account to
    /// post to.
    private func seedTwitterTokens() async throws {
        let oauthTokenID = try UUID.unwrapFromString("cc27b4c0-3f7d-4b56-9bc0-7b69d5e84dd6") {
            app.logger.error(
                "Could not convert seed oauth token ID to UUID, this should never happen.",
                metadata: [
                    "to": .string("seedDatabase")
                ]
            )
        }

        if try await TwitterOAuthToken.doesExist(id: oauthTokenID, on: app.db) {
            return
        }

        try await TwitterOAuthToken(
            id: oauthTokenID,
            oauthToken: "buf3NwAAAAABzwgpAAABlucYrjg",
            oauthTokenSecret: "aQfxpLSgjAVItP1YOt8z76lw6rZCoql6",
            oauthCallbackConfirmed: true
        )
        .create(on: app.db)

        let userTokenID = try UUID.unwrapFromString("df2f5fc3-29f0-4db6-8ac5-617f0fbb99e9") {
            app.logger.error(
                "Could not convert seed user token ID to UUID, this should never happen.",
                metadata: [
                    "to": .string("seedDatabase")
                ]
            )
        }

        if try await TwitterUserToken.doesExist(id: userTokenID, on: app.db) {
            return
        }

        try await TwitterUserToken(
            id: userTokenID,
            accessToken: "1859607209115619328-zJItUeikeKz0kTIVBHxzJqoZIm2WU3",
            secretAccessToken: "02AjnKy6YX7O0XhKtFuRhpOW5jhwxZC3ZFFW5vT7WHaLz",
            oauthVerifier: "XJwcVmY9IQ9CEpTPHGvTt3Ym99mXyTvj",
            oauthTokenID: oauthTokenID
        ).create(on: app.db)
    }
}

internal enum DatabaseURLs {
    static let primary: Result<String, Error> = Result { try Environment.getOrThrow("PRIMARY_POSTGRES_URL") }
    static let regional: Result<String, Error> = Result { try Environment.getOrThrow("REGIONAL_POSTGRES_URL") }
}
