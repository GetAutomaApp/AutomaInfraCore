// AutomaWebCoreClientIntegrationTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

@Suite("AutomaWebCoreClientIntegrationTests")
internal struct AutomaWebCoreClientIntegrationTests: MinimalVaporApplicationTestSuite {
    /// Tests that getting the HTML of a website using `AutomaWebCoreClient` is a success
    ///
    /// - Throws: Any errors that occur during the test execution, including:
    ///   - Client initialization errors
    ///   - Network errors
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
