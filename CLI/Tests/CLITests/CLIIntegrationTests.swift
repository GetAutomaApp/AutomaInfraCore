// CLIIntegrationTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import AutomaCLI
import Testing

// boilerplate code here, not real tests

@Suite("Integration test suite", .serialized)
internal struct CLIIntegrationTests {
    /// A description
    /// - Parameters:
    ///
    /// - Throws:
    @Test("Fake Integration Test")
    public func helloWorld() throws {
        print("Hello, world!")
    }
}
