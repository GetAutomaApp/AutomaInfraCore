// IOSAdminUILaunchTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import XCTest

/// UI launch test suite for the iOS Admin application
///
/// This test class verifies the launch behavior and initial UI state of the iOS Admin app.
/// It captures screenshots of the launch process and handles basic test setup.
public final class IOSAdminUILaunchTests: XCTestCase {
    /// Indicates whether tests should run for each UI configuration
    ///
    /// When true, tests will run separately for each UI configuration (like light/dark mode)
    /// to ensure consistent behavior across different display settings.
    override public static var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    /// Sets up the test environment before each test
    ///
    /// Configures the test case to stop execution immediately when a failure occurs
    /// rather than attempting to continue running subsequent steps.
    override public func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Tests the application launch process
    ///
    /// This test:
    /// 1. Launches the application
    /// 2. Takes a screenshot of the initial launch state
    /// 3. Saves the screenshot as a permanent test artifact
    ///
    /// The test provides a point for adding additional launch verification steps
    /// such as checking initial UI elements or performing setup navigation.
    @MainActor
    public func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Cleanup when the test class is deallocated
    deinit {
        return
    }
}
