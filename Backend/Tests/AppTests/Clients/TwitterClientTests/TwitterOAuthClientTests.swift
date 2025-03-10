// TwitterOAuthClientTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

@Suite("Twitter OAuth Client Tests")
struct TwitterOAuthClientTests {
    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await app.autoMigrate()
            try await test(app)
            try await app.autoRevert()
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Test Request Token")
    func requestToken() async throws {
        try await withApp { app in
            let client = try TwitterOAuthClient(
                client: app.client,
                logger: app.logger,
                consumerKey: Environment.getOrThrow("TWITTER_API_KEY"),
                consumerSecret: Environment.getOrThrow("TWITTER_API_KEY_SECRET")
            )
            let requestToken = try await client.getRequestToken()
            print(requestToken)
        }
    }
}
