// ProgressIndicatorComponentTests.swift
// was created on 11/29/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI
import ViewInspector
import XCTest

@testable import AutomaUIKit

class ProgressIndicatorComponentTests: XCTestCase {
    @MainActor func testIntegration() throws {
        let config = ProgressIndicatorComponentConfig()
        let component = ProgressIndicatorComponent(config: config)
        XCTAssertNotNil(component)
    }

    @MainActor func testOnSelfAppearIsFunctional() throws {
        var IGotCalledAmount = 0
        let onSelfAppear: (ProgressIndicatorComponentConfig) -> Void = {
            _ in IGotCalledAmount += 1
        }

        let config = ProgressIndicatorComponentConfig()
        let component = ProgressIndicatorComponent(
            config: config,
            onSelfAppear: onSelfAppear
        )

        try component.inspect().find(ViewType.ZStack.self).callOnAppear()

        XCTAssertNotNil(component)
        XCTAssertEqual(IGotCalledAmount, 1)
    }

    @MainActor func testIsIncrementDecrementAndSetWorking() throws {
        let config = ProgressIndicatorComponentConfig()
        let component = ProgressIndicatorComponent(
            config: config
        )
        XCTAssertNotNil(component)

        // Increment Tests
        // Increment by one until we reach max
        config.setStep(1)
        XCTAssertEqual(config.currentStep, 1)
        let maxStep = config.totalSteps

        for step in 2 ... maxStep {
            config.incrementStep()
            XCTAssertEqual(config.currentStep, step)
            XCTAssertLessThanOrEqual(config.currentStep, maxStep)
        }
        // Increment by total count (shouldn't go over)
        config.setStep(1)
        XCTAssertEqual(config.currentStep, 1)
        config.incrementStep(maxStep) // if the guard fails we will be at maxStep + 1
        XCTAssertEqual(config.currentStep, maxStep)

        // Decrement Tests
        config.setStep(maxStep)
        XCTAssertEqual(config.currentStep, maxStep)

        for step in (1 ... maxStep - 1).reversed() {
            config.decrementStep()
            XCTAssertEqual(config.currentStep, step)
            XCTAssertGreaterThanOrEqual(config.currentStep, 1)
        }

        // Decrement by total count (shouldn't become less than 1)
        config.setStep(maxStep)
        XCTAssertEqual(config.currentStep, maxStep)
        config
            .decrementStep(
                maxStep
            ) // If the guard fails we will be at 0
        XCTAssertEqual(config.currentStep, 1)

        // Set Tests
        config.setStep(1)
        XCTAssertEqual(config.currentStep, 1)
        config.setStep(maxStep * 2)
        XCTAssertEqual(config.currentStep, 1)

        config.setStep(0)
        XCTAssertEqual(config.currentStep, 1)

        config.setStep(maxStep)
        XCTAssertEqual(config.currentStep, maxStep)
    }
}
