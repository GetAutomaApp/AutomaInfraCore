// IOSAdminUILaunchTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import XCTest

/// UI launch test suite for the iOS application
///
/// This test class contains UI tests that verify the launch behavior and appearance
/// of the iOS app through automated UI testing. It captures screenshots of the launch
/// process for visual verification.
public class IOSAdminUILaunchTests: XCTestCase {
    /// Indicates whether tests should run for each UI configuration
    ///
    /// When true, tests will run for each supported device configuration
    /// (e.g. light/dark mode, different accessibility settings)
    override public class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    /// Sets up the test environment before running any tests
    ///
    /// This method configures the test case to stop immediately on failure
    /// to prevent cascading test failures.
    ///
    /// - Throws: An error if the setup process fails
    override public func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Tests and documents the application launch process
    ///
    /// This test:
    /// 1. Launches the application
    /// 2. Takes a screenshot of the launch screen
    /// 3. Saves the screenshot as a test attachment
    ///
    /// - Throws: An error if the test fails or if the app fails to launch
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
