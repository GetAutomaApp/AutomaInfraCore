// TwitterAuthenticatedClientTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Fluent
import Testing
import VaporTesting

@Suite("Twitter Authenticated Client Tests")
struct TwitterAuthenticatedClientTests {
    private func withApp(test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configureDatabase(app: app)
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Post Tweet")
    func postTweet() async throws {
        try await withApp { app in
            let testTwitterUserTokenID = try Environment.getOrThrow("TEST_TWITTER_USER_TOKEN_ID")
            guard
                let twitterUserTokenID = UUID(uuidString: testTwitterUserTokenID)
            else {
                try #require(
                    Bool(false),
                    "Failed to convert test Twitter User Token ID of value '\(testTwitterUserTokenID)' to UUID."
                )
                return
            }

            guard
                let token = try await TwitterUserToken.query(on: app.db)
                .filter(\.$id == twitterUserTokenID)
                .first()
            else {
                try #require(Bool(false), "failed to find Twitter User Token.")
                return
            }

            let client = try TwitterClient(
                logger: app.logger,
                client: app.client,
                database: app.db
            ).authenticated(token: token.toDTO())

            let message = UUID().uuidString
            let response = try await client.postTweet(message: message)
            #expect(response.data.text == message, "Tweet message should match")
        }
    }
}
