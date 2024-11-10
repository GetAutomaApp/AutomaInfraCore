// ButtonFrameComponentTests.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp. All rights reserved.

import SwiftUI
import ViewInspector
import XCTest

@testable import AutomaUIKit

class ButtonFrameComponentTests: XCTestCase {
    @MainActor func testShouldExecuteCodeInAction() throws {
        var didRun = false

        let view = ButtonFrameComponent(action: { _ in didRun.toggle() }) { _ in EmptyView() }

        let button = try view.inspect().find(ViewType.Button.self)

        try button.tap()

        XCTAssertTrue(didRun, "The action should toggle the didRun flag.")
    }
}
