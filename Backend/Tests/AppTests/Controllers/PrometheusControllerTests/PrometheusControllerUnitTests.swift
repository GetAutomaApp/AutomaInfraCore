// PrometheusControllerUnitTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

@Suite("PrometheusControllerUnitTests")
struct PrometheusControllerUnitTests {
    private func withApp(test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        try await startPrometheusService()
        try await test(app)
        try await app.asyncShutdown()
    }

    @Test("Test Prometheus Metrics")
    func testRequest() async throws {
        try await withApp { app in
            let url = try "\(Environment.getOrThrow("PROMETHEUS_BASE_URL"))/Prometheus/metrics"
            let res = try await app.client.get(.init(string: url))
            #expect(res.status == .ok)
        }
    }
}
