// AppLaunchControllerIntegrationTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import XCTVapor

final class AppLaunchControllerIntegrationTests: XCTestCase {
    var app: Application!

    override func setUp() async throws {
        app = try! await Application.make(.testing)
        try! await configure(app)
    }

    override func tearDown() {
        app.shutdown()
    }

    func testRequest() throws {
        try app.test(.GET, "App-Launch/request") { res in
            XCTAssertEqual(res.status, .ok)
            // Add more assertions based on the expected response
        }
    }
}
