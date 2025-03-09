// AppLaunchControllerUnitTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

@Suite("App Launch Controller Unit Tests")
final class AppLaunchControllerUnitTests {
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

    @Test("Test Hello World")
    func testRequest() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "App-Launch/request") { res async in
                #expect(res.status == .ok)
            }
        }
    }
}
