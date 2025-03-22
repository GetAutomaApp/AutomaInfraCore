// PrometheusControllerIntegrationTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

@Suite("Prometheus Controller Integration Tests")
final class PrometheusControllerIntegrationTests {
    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        try await test(app)
        try await app.asyncShutdown()
    }

    @Test("Test Request")
    func testRequest() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "Prometheus/request") { res async in
                #expect(res.status == .ok)
            }
        }
    }
}
