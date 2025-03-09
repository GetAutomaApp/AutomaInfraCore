// CLITest.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import AutomaCLI
import Fluent
import Testing

// boilerplate code here, not real tests

@Suite("Fake test suite", .serialized)
struct AppTests {
    @Test("Fake test")
    func helloWorld() async throws {
        print("Hello, world!")
    }
}
