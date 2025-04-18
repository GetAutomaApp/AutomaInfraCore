// PrometheusControllerIntegrationTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

@Suite("Prometheus Controller Integration Tests")
public final class PrometheusControllerIntegrationTests {
    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try app.register(collection: PrometheusController())
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Test Request")
    public func testRequest() async throws {
        try await withApp { app in
            let token = try Environment.getOrThrow("FLY_METRICS_TOKEN")
            try await app.testing().test(.GET, "Prometheus/metrics?auth_token=\(token)") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    deinit {}
}
