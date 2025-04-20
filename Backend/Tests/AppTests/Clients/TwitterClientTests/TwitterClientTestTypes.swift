// TwitterClientTestTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Testing
import VaporTesting

/// Protocol defining common functionality for Twitter client test suites
/// This protocol provides shared test utilities used across different Twitter client implementations
protocol TwitterClientTestSuite {}

extension TwitterClientTestSuite {
    /// Helper function to create and manage a test application instance
    /// Creates a test application, configures the database, runs the provided test closure, and ensures proper cleanup
    ///
    /// - Parameter test: The test closure to execute with the application instance
    /// - Throws: Any errors that occur during test execution, including:
    ///   - Application initialization errors
    ///   - Database configuration errors
    ///   - Test execution errors
    ///   - Shutdown errors
    private func withApp(test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            // Configure the database for the application
            try await configureDatabase(app: app)
            // Execute the test closure with the application instance
            try await test(app)
        } catch {
            // Shut down the application in case of errors
            try await app.asyncShutdown()
            throw error
        }
        // Ensure proper cleanup by shutting down the application
        try await app.asyncShutdown()
    }
}
