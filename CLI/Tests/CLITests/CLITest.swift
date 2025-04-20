// CLITest.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import AutomaCLI
import Testing

/// A fake test suite for demonstration purposes.
/// This suite contains boilerplate code and does not perform real tests.
@Suite("Fake test suite", .serialized)
internal struct AppTests {
    /// A fake test method that prints "Hello, world!".
    /// This method serves as a placeholder for real test implementations.
    @Test("Fake test")
    public func helloWorld() throws {
        // Print a greeting message to the console
        print("Hello, world!")
    }
}
