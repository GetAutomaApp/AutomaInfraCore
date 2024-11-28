// IconButtonComponentTests.swift
// was created on 10/23/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI
import ViewInspector
import XCTest

@testable import AutomaUIKit

class IconButtonComponentTests: XCTestCase {
    // MARK: - Test Variant Styling Changes

    @MainActor func testVariantStylingChanges() throws {
        let config = IconButtonComponentConfig()

        // Test generic variant
        config.variant = .generic
        XCTAssertFalse(config.isCircular, "Generic variant should not be circular")
        XCTAssertEqual(
            config.roundness,
            DesignTokens.defaultCornerRadius,
            "Generic variant should have default corner radius"
        )
        XCTAssertTrue(config.fillSpace, "Generic variant should fill space")

        // Test square variant
        config.variant = .square
        XCTAssertFalse(config.isCircular, "Square variant should not be circular")
        XCTAssertEqual(
            config.roundness,
            DesignTokens.defaultCornerRadius,
            "Square variant should have default corner radius"
        )
        XCTAssertFalse(config.fillSpace, "Square variant should not fill space")
        XCTAssertEqual(
            config.defaultPadding,
            DesignTokens.padding.buttonEven,
            "Square variant should use buttonEven padding"
        )

        // Test circle variant
        config.variant = .circle
        XCTAssertTrue(config.isCircular, "Circle variant should be circular")
        XCTAssertFalse(config.fillSpace, "Circle variant should not fill space")
        XCTAssertEqual(
            config.defaultPadding,
            DesignTokens.padding.buttonEven,
            "Circle variant should use buttonEven padding"
        )

        // Test pill variant
        config.variant = .pill
        XCTAssertTrue(config.isCircular, "Pill variant should be circular")
        XCTAssertTrue(config.fillSpace, "Pill variant should fill space")
        XCTAssertEqual(
            config.defaultPadding,
            DesignTokens.padding.button,
            "Pill variant should use default button padding"
        )
    }

    // MARK: - Test Disabled State Management

    @MainActor func testDisabledStateManagement() throws {
        let config = IconButtonComponentConfig()

        // Test enabled state
        config.isDisabled = false
        XCTAssertEqual(config.frameVariant, .generic, "Enabled state should have generic frame variant")

        // Test disabled state
        config.isDisabled = true
        XCTAssertEqual(config.frameVariant, .disabled, "Disabled state should have disabled frame variant")
    }

    // TODO: - Test the rest of this component
}
