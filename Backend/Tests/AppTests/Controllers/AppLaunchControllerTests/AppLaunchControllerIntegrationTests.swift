// AppLaunchControllerIntegrationTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

@Suite("App Launch Controller Integration Tests")
public final class AppLaunchControllerIntegrationTests {
    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configureDatabase(app: app)
            try app.register(collection: AppLaunchController())
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    // TODO: Implement when fixing issue 135
    @Test("Is User Accepted")
    public func testRequest() {
        #expect(Bool(true))
    }

    deinit {
        return
    }
}
