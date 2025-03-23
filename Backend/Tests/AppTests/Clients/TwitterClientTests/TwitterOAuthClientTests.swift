// TwitterOAuthClientTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

@Suite("Twitter OAuth Tests")
struct TwitterOAuthClientTests {
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

    @Test("Test Request Token")
    func requestToken() async throws {
        try await withApp { app in
            let twitterClient = try TwitterClient(logger: app.logger, client: app.client, database: app.db)
            let token = try await twitterClient.auth.requestToken()

            #expect(token.oauthToken.count > 5, "OAuth token should have more than 5 characters")
            #expect(token.oauthTokenSecret.count > 5, "OAuth token secret should have more than 5 characters")
        }
    }

    @Test("Make Authenticate URL")
    func makeAuthenticateURL() async throws {
        try await withApp { app in
            let twitterClient = try TwitterClient(logger: app.logger, client: app.client, database: app.db)
            let token = try await twitterClient.auth.requestToken()
            #expect(token.oauthToken != "", "OAuth token should not be empty")
            #expect(token.oauthTokenSecret != "", "OAuth token secret should not be empty")

            let url = try await twitterClient.auth.makeAuthenticateURL(tokenObject: token)
            let expected = "https://api.twitter.com/oauth/authenticate?oauth_token=\(token.oauthToken)"
            #expect(url.absoluteString == expected, "URL should match expected URL")
        }
    }
}
