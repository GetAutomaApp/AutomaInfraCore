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
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(ErrorStringMiddleware())

    // Errors are getting thrown locally, this prevents run App & ./App execution diffs
    let environment = Environment.get("ENVIRONMENT") ?? "local"
    if environment != "local" {
        app.asyncCommands.use(QueuesCommand(application: app), as: "vapor-queues")
    }

    let primaryDatabaseURL = Environment.get("PRIMARY_POSTGRES_URL")

    let regionalDatabaseURL = Environment.get("REGIONAL_POSTGRES_URL")

    let hasDatabaseUrls = primaryDatabaseURL != nil && regionalDatabaseURL != nil

    // keep this here while `AppTests.swift` is empty
    app.get("hello") { _ in
        "Hello, world!"
    }

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
        app.migrations.add(RemoveUserStorageMigration1739456565())
        app.migrations.add(AddAcceptedColumnMigration1740658649())
        app.migrations.add(RSSFeedMigration1741359416())
        app.migrations.add(UserFeedMappingMigration1741429746())
        app.migrations.add(RssFeedItemMigration1741876963())

        try await app.autoMigrate()

        try app.register(collection: AuthenticationController())
        try app.register(collection: AppLaunchController())
        try app.register(collection: TwitterController())
        try app.register(collection: ChatCompletionController())
        try app.register(collection: FeedTesterController())
        try app.register(collection: FirecrawlTestController())

        // Authentication
        await app.jwt.keys
            .add(hmac: .init(stringLiteral: Environment.get("JWT_ENCRYPTION_SECRET")!), digestAlgorithm: .sha256)

        // Queues
        app.queues.use(.fluent(useSoftDeletes: true))
        app.queues.configuration.workerCount = 1
        app.queues.configuration.refreshInterval = .seconds(5)

        // Jobs
        app.queues.add(TransactionalMessageAsyncJob())
        app.queues.add(ProfilePictureAsyncJob())
//        app.queues.scheduleEvery(ScrapeRSSFeedCronJob(), minutes: 5)

        // Http Server Config
        app.http.server.configuration.responseCompression = .enabled

        let response = try await Crawl4AIClient(apiKey: "your_secret_token").crawl(urls: ["https://simonferns.com"])
        print("\(response)")
    }
}

extension DatabaseID {
    static let primary = DatabaseID(string: "primary")
    static let readOnly = DatabaseID(string: "readOnly")
}

extension Request {
    var dbWrite: Database {
        db(.readOnly)
    }

    var dbReadOnly: Database {
        db(.readOnly)
    }
}

extension QueueContext {
    var dbWrite: Database {
        application.db(.readOnly)
    }

    var dbReadOnly: Database {
        application.db(.readOnly)
    }
}

extension Application.Queues {
    func scheduleEvery(_ job: ScheduledJob, minutes: Int) {
        for minuteOffset in stride(from: 0, to: 60, by: minutes) {
            schedule(job).hourly().at(.init(integerLiteral: minuteOffset))
        }
    }
}
