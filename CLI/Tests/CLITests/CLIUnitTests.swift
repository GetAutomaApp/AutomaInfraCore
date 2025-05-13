// CLIUnitTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import AutomaCLI
import Testing

// boilerplate code here, not real tests

@Suite("Unit test suite", .serialized)
struct CLIUnitTests {
    /// A description
    /// - Parameters:
    ///
    /// - Throws:
    @Test("Fake Unit test")
    public func helloWorld() throws {
        print("Hello, world!")
    }
}
