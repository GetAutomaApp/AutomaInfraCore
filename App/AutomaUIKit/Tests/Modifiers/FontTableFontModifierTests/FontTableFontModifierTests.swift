// FontTableFontModifierTests.swift
// was created on 10/23/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI
import ViewInspector
import XCTest

@testable import AutomaUIKit

class FontTableFontComponentTests: XCTestCase {
    // one test case per method
    // one test case per completed flow (action)
    // one test case per potential edge-case
    @MainActor func testIntegration() throws {
        // let component = Text("HI").__crimsonFont()
        // XCTAssertNotNil(component)
    }

    // Make sure the correct colour is applied
    @MainActor func testColour() throws {
        let color = DesignTokens.colors.primaryText

        let component = Text("HI").fontTableFont(FontTable.Body.body1, color)

        let sut = try component.inspect()
    }

    // Make sure the custom font input works
    @MainActor func testFont() throws {
        let font = FontTable.Body.body1
        let component = Text("HI").fontTableFont(FontTable.Body.body1)

        let _ = try component.inspect().find(textWithFont: font.font)
    }
}
