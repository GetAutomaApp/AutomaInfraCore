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

// TODO:
// 1. Delete 3 compose services and their volumes
// 2. Start up the 3 compose services: docker-compose up postgres localstack worker_dev -d
// 3. Build app (`swift build`) and run migrations (`swift run App migrate --yes`)
// 4. Run app (`swift run App`)
// 5. Run tests (`swift test -Xswiftc -warnings-as-errors --filter '.*IntegrationTests.*'`)
// 6. Tests should work, because the user token gets created. if not, debug why and fix it
// 7. Delete user token id and oauth token id variables in all envs except for .env.testing
// 8. Update/create `TEST_TWITTER_OAUTH_TOKEN_ID` and `TEST_TWITTER_USER_TOKEN_ID` as Github secrets
// 9. Create a new optional argument in `swifttesting` to run a command right before running the tests
//  (right after all the required services are healthy - add worker_dev as a required service as well).
// 10. Update `automa-backend-testing.yml` to run migrations before running tests (`swift run App migrate --yes`)

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
        // TODO: get ID from env
        let oauthTokenID = try UUID.unwrapFromString(Environment.getOrThrow("TEST_TWITTER_OAUTH_TOKEN_ID")) {
            app.logger.error(
                "Could not convert seed oauth token ID to UUID, this should never happen.",
                metadata: [
                    "to": .string("seedDatabase")
                ]
            )
        }

        try await createTwitterOAuthTokenIfNotExist(id: oauthTokenID)

        let userTokenID = try UUID.unwrapFromString("TEST_TWITTER_USER_TOKEN_ID") {
            app.logger.error(
                "Could not convert seed user token ID to UUID, this should never happen.",
                metadata: [
                    "to": .string("seedDatabase")
                ]
            )
        }

        try await createUserTokenIfNotExist(id: userTokenID, oauthTokenID: oauthTokenID)
    }

    private func createTwitterOAuthTokenIfNotExist(id: UUID) async throws {
        if try await TwitterOAuthToken.doesExist(id: id, on: app.db) {
            return
        }

        try await TwitterOAuthToken(
            id: id,
            oauthToken: "4Fdi9gAAAAABzwgpAAABlznYxEc",
            oauthTokenSecret: "8eWirhncJQoO5pQnSjDiuSbHvKsbh0st",
            oauthCallbackConfirmed: true
        )
        .create(on: app.db)
    }

    private func createUserTokenIfNotExist(id _: UUID, oauthTokenID: UUID) async throws {
        if try await TwitterUserToken.doesExist(id: userTokenID, on: app.db) {
            return
        }
        try await TwitterUserToken(
            id: userTokenID,
            accessToken: "1930140743508578304-OLUSXEnpgk3pXmom9gyXg4jlYQOtRR",
            secretAccessToken: "rl9EdJzgUv9aMpUYeO9vHxSOhUk5d71jUydL4CFAHMsXn",
            oauthVerifier: "gbkH02mARsyXak7VSGyiTKohlcLT6Kea",
            oauthTokenID: oauthTokenID
        ).create(on: app.db)
    }
}

internal enum DatabaseURLs {
    static let primary: Result<String, Error> = Result { try Environment.getOrThrow("PRIMARY_POSTGRES_URL") }
    static let regional: Result<String, Error> = Result { try Environment.getOrThrow("REGIONAL_POSTGRES_URL") }
}
