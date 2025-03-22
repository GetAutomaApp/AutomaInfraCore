// PrometheusControllerUnitTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

@Suite("PrometheusControllerUnitTests")
struct PrometheusControllerUnitTests {
    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        try app.register(collection: PrometheusController())
        try await test(app)
        try await app.asyncShutdown()
    }

    @Test("testRequest")
    func testRequest() async throws {
        try await withApp { app in
            let token = try Environment.getOrThrow("FLY_METRICS_TOKEN")
            try await app.testing().test(.GET, "Prometheus/metrics?auth_token=\(token)") { res async in
                #expect(res.status == .ok)
            }
        }
    }
}
