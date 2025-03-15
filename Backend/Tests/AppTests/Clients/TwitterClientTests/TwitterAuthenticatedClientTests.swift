// TwitterAuthenticatedClientTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Fluent
import Testing
import Vapor
import VaporTesting
import XCTest

@Suite("Twitter Authenticated Client Tests")
struct TwitterAuthenticatedClientTests {
    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await test(app)
        } catch {
            app.logger.error(
                "Failed to create app for suite 'TwitterAuthenticatedClientTests'",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(String(String(reflecting: error))),
                ]
            )
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
                app.logger.error(
                    "Failed to convert test Twitter User Token ID to UUID.",
                    metadata: [
                        "to": .string("\(String(describing: Self.self)).\(#function)"),
                        "testTwitterUserTokenID": .string(testTwitterUserTokenID),
                    ]
                )
                throw Abort(.internalServerError)
            }

            guard
                let token = try await TwitterUserToken.query(on: app.db)
                .filter(\.$id == twitterUserTokenID)
                .first()
            else {
                XCTFail("Failed to get Twitter User Token.")
                return
            }

            let client = try TwitterClient(
                logger: app.logger,
                client: app.client,
                database: app.db
            ).authenticated(token: token.toDTO())

            let message = UUID().uuidString
            let response = try await client.postTweet(message: message)
            XCTAssertEqual(message, response.data.text)
        }
    }
}
