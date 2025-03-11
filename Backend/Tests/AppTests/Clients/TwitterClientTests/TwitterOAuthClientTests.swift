// TwitterOAuthClientTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Testing
import VaporTesting
import XCTest

@Suite("Twitter OAuth Tests")
struct TwitterOAuthClientTests {
    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await test(app)
        } catch {
            app.logger.error(
                "Failed to create app for suite 'TwitterClientTests'",
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

    @Test("Test Request Token")
    func requestToken() async throws {
        try await withApp { app in
            let twitterClient = try TwitterClient(logger: app.logger, client: app.client, database: app.db)
            let token = try await twitterClient.auth.requestToken()

            XCTAssert(token.oauthToken != "")
            XCTAssert(token.oauthTokenSecret != "")
        }
    }

    @Test("Make Authenticate URL")
    func makeAuthenticateURL() async throws {
        try await withApp { app in
            let twitterClient = try TwitterClient(logger: app.logger, client: app.client, database: app.db)
            let token = try await twitterClient.auth.requestToken()
            XCTAssert(token.oauthToken != "")
            XCTAssert(token.oauthTokenSecret != "")

            let url = try await twitterClient.auth.makeAuthenticateURL(tokenObject: token)
            let expected = "https://api.x.com/oauth/authenticate?oauth_token=\(token.oauthToken)"
            XCTAssert(url.absoluteString == expected)
        }
    }
}
