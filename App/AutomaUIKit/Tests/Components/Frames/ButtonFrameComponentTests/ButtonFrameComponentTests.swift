// ButtonFrameComponentTests.swift
// was created on 11/6/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI
import ViewInspector
import XCTest

@testable import AutomaUIKit

class ButtonFrameComponentTests: XCTestCase {
  // MARK: - Test Action Execution

  @MainActor func testShouldExecuteCodeInAction() throws {
    var didRun = false

    let view = ButtonFrameComponent(action: { _ in didRun.toggle() }) { _ in EmptyView() }

    let button = try view.inspect().find(ViewType.Button.self)

    // Simulate button tap
    try button.tap()

    // Assert that the action toggled the flag
    XCTAssertTrue(didRun, "The action should toggle the didRun flag.")
  }

  // MARK: - Test Button Disabled State

  @MainActor func testShouldDisableButtonWhenDisabledVariant() throws {
    let config = ButtonFrameComponentConfig()
    config.frameVariant = .disabled // Setting the frame variant to .disabled

    let view = ButtonFrameComponent(config: config, action: { _ in }) { _ in Text("Disabled Button") }

    let button = try view.inspect().find(ViewType.Button.self)

    // Assert the button is disabled
    XCTAssertTrue(button.isDisabled(), "The button should be disabled when the frame variant is 'disabled'.")
  }

  // MARK: - Test Button Circular State

  @MainActor func testShouldRespectCircularConfiguration() throws {
    let config = ButtonFrameComponentConfig()
    config.isCircular = true // Setting the button to be circular

    let view = ButtonFrameComponent(config: config, action: { _ in }) { _ in Text("Circular Button") }

    let button = try view.inspect().find(ViewType.Button.self)

    // Check the corner radius to confirm it's circular
    let cornerRadius = try button.cornerRadius()

    // Assert that the corner radius is set to infinity for circular buttons
    XCTAssertEqual(cornerRadius, CGFloat.infinity, "The corner radius should be infinite for circular buttons.")
  }

  // MARK: - Test Button Roundness

  @MainActor func testShouldRespectButtonCornerRoundness() throws {
    let config = ButtonFrameComponentConfig()
    config.roundness = 12 // Custom roundness value

    let view = ButtonFrameComponent(config: config, action: { _ in }) { _ in Text("Roundness Test Button") }

    let button = try view.inspect().find(ViewType.Button.self)

    // Inspect the corner radius applied to the button
    let cornerRadius = try button.cornerRadius()

    XCTAssertEqual(cornerRadius, 12, "The button should respect the corner roundness configuration.")
  }

  // MARK: - Test Reset Button Roundness

  @MainActor func testShouldResetButtonRoundness() throws {
    let config = ButtonFrameComponentConfig()
    config.roundness = 24 // Set a custom roundness

    let view = ButtonFrameComponent(
      config: config,
      action: { conf in conf.roundness = DesignTokens.defaultCornerRadius }
    ) { _ in
      Text("Reset Roundness Test")
    }

    // Simulate tapping the reset button to reset roundness
    let button = try view.inspect().find(ViewType.Button.self)

    // Simulate tapping the Reset button
    try button.tap()

    // Assert that the roundness is reset to the default value
    XCTAssertEqual(
      config.roundness,
      DesignTokens.defaultCornerRadius,
      "The roundness should be reset to the default value when tapped."
    )
  }

  // MARK: - Test Multiple Buttons with Different Configurations

  @MainActor func testShouldDisplayMultipleButtonsWithDifferentConfigs() throws {
    let config1 = ButtonFrameComponentConfig()
    config1.frameVariant = .generic
    let view1 = ButtonFrameComponent(config: config1, action: { _ in }) { _ in Text("Generic Button") }

    let config2 = ButtonFrameComponentConfig()
    config2.frameVariant = .disabled
    let view2 = ButtonFrameComponent(config: config2, action: { _ in }) { _ in Text("Disabled Button") }

    let view = VStack {
      view1
      view2
    }

    let stack = try view.inspect().vStack()

    // Assert that both buttons are in the stack
    XCTAssertEqual(stack.count, 2, "The stack should contain two buttons.")
  }

  // MARK: - Test Multiple Buttons should modify the same config

  @MainActor func testShouldUseTheSameConfigForMultipleButtons() throws {
    let config = ButtonFrameComponentConfig()

    let view1 = ButtonFrameComponent(
      config: config,
      action: { config in
        config.frameVariant = .disabled
      }
    ) {
      Text("Disabled Button")
    }

    let view2 = ButtonFrameComponent(
      config: config,
      action: { config in
        config.frameVariant = .generic
      }
    ) {
      Text("Generic Button")
    }

    let button1 = try view1.inspect().find(ViewType.Button.self)
    try button1.tap()

    XCTAssertEqual(config.frameVariant, .disabled, "The first button should update the config to 'disabled'.")

    let button2 = try view2.inspect().find(ViewType.Button.self)

    do {
      // We expect this to throw an error
      try button2.tap()
      XCTAssertEqual(true, false, "ViewInspector .tap() should've thrown an 'unresponsive view' error.")
    } catch {}
  }
}
