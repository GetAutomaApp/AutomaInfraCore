// FontTableFontModifierTests.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI
import ViewInspector
import XCTest

@testable import AutomaUIKit

class FontTableFontComponentTests: XCTestCase {
    // Make sure the correct colour is applied
    @MainActor func testColour() throws {
        let color = DesignTokens.colors.primaryText

        let component = Text("HI").fontTableFont(FontTable.Body.body1, color)
    }

    // Make sure the custom font input works
    @MainActor func testFont() throws {
        let font = FontTable.Body.body1
        let component = Text("HI").fontTableFont(FontTable.Body.body1)

        let _ = try component.inspect().find(textWithFont: font.font)
    }
}
