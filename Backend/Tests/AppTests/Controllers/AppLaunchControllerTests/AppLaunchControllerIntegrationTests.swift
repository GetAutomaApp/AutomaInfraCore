// AppLaunchControllerIntegrationTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

@Suite("App Launch Controller Integration Tests")
final class AppLaunchControllerIntegrationTests {
    var app: Application!

    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Test Application Launch Request")
    func testRequest() async throws {
        try await app.test(.GET, "App-Launch/request") { res in
            #expect(res.status == .ok)
        }
    }
}
