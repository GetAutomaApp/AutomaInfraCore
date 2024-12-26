// MessageServiceUnitTests.swift
// was created on 12/25/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import XCTVapor

final class MessageControllerUnitTests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = Application(.testing)
        try! configure(app)
    }

    override func tearDown() {
        app.shutdown()
    }

    func testRequest() throws {
        try app.test(.GET, "Message/request") { res in
            XCTAssertEqual(res.status, .ok)
            // Add more assertions based on the expected response
        }
    }
}
