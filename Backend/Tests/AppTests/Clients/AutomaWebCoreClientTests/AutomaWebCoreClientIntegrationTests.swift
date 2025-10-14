// AutomaWebCoreClientIntegrationTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

@Suite("AutomaWebCoreClientIntegrationTests")
internal struct AutomaWebCoreClientIntegrationTests {
    public func withApp(test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Get Website HTML Success")
    public func getWebsiteHTMLSuccess() async throws {
        try await withApp { app in
            let response = try await AutomaWebCoreClient(client: app.client)
                .getWebsiteHTML(
                    payload: .init(
                        url: URL.fromString(
                            payload: .init(
                                string: "https://williamferns.org"
                            )
                        )
                    )
                )
            #expect(response.count > 100)
        }
    }
}
