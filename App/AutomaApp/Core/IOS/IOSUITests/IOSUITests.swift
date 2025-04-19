// IOSUITests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import XCTest

/// A test case class for UI testing of the iOS application
///
/// This class contains UI tests to verify the application's user interface behavior and performance
public class IOSUITests: XCTestCase {
    /// Sets up the test environment before each test method is executed
    ///
    /// This method is called before the invocation of each test method in the class.
    /// It configures the test environment by:
    /// - Disabling continue after failure to stop tests immediately when a failure occurs
    /// - Setting up initial interface state required for tests
    override public func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Tears down the test environment after each test method is executed
    ///
    /// This method is called after the invocation of each test method in the class
    /// to clean up any resources or state that were set up during the test.
    override public func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// Tests basic functionality of the application
    ///
    /// This test method launches the application and can be extended to verify
    /// specific UI behaviors and interactions
    @MainActor
    public func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    /// Measures the launch performance of the application
    ///
    /// This test method measures how long it takes to launch the application
    /// using XCTest metrics. It is only available on newer OS versions.
    /// - Throws: An error if the performance measurement fails
    @MainActor
    public func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    /// Cleanup when the test case is deallocated
    deinit {
        return
    }
}
