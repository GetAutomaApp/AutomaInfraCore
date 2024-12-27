// TigrisServiceIntegrationTests.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import XCTVapor

final class TigrisControllerIntegrationTests: XCTestCase {
    func testTigrisS3PathSplitting() throws {
        let tigris = try TigrisService()

        let s3Path = "s3://bucket/key"
        let splitPath = try tigris.decodeS3Path(s3Path)

        XCTAssertEqual(splitPath.bucket, "bucket")
        XCTAssertEqual(splitPath.key, "key")
    }
}
