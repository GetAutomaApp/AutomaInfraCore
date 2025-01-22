// InfoPairComponentTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI
import ViewInspector
import XCTest

@testable import AutomaUIKit

class InfoPairComponentTests: XCTestCase {
    // MARK: - Test 1: Component Initialization (Integration Test)

    @MainActor func testIntegration() throws {
        let component = InfoPairComponent()
        XCTAssertNotNil(component)
    }

    // MARK: - Test 2: Check for Title and Description Texts

    @MainActor func testHasTitleAndDescription() throws {
        // Given: A InfoPairComponent with a title and description
        let component = InfoPairComponent(config: .init(
            title: "Sample Title",
            description: "This is a sample description"
        ))

        // When: Inspect the view
        let title = try component.inspect().find(viewWithTag: "title")
        let description = try component.inspect().find(viewWithTag: "description")

        let titleText = try title.find(text: "Sample Title").string()
        let descriptionText = try description.find(text: "This is a sample description").string()

        // Assert: Values are as expected
        XCTAssertEqual(titleText, "Sample Title")
        XCTAssertEqual(descriptionText, "This is a sample description")
    }
}
