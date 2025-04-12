// TwitterAuthenticatedClientTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Fluent
import Testing
import VaporTesting

/// Test suite for the authenticated Twitter client functionality
/// These tests verify that operations requiring user authentication work correctly
@Suite("Twitter Authenticated Client Tests")
struct TwitterAuthenticatedClientTests: TwitterClientTestSuite {
    /// Tests the ability to post a tweet using an authenticated Twitter client
    /// This test verifies that:
    /// - A valid Twitter user token can be retrieved from the database
    /// - An authenticated client can be created with the token
    /// - A tweet can be successfully posted
    /// - The posted tweet contains the expected message
    ///
    /// - Throws: Any errors that occur during test execution, including:
    ///   - Environment variable retrieval errors
    ///   - Database query errors
    ///   - Client initialization errors
    ///   - API request failures
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
                try #require(Bool(false), "Failed to find Twitter User Token.")
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
