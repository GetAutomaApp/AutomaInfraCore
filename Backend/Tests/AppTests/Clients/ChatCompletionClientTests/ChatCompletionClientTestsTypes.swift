// ChatCompletionClientTestsTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import VaporTesting

/// Protocol defining common functionality for chat completion client test suites
/// This protocol provides shared test utilities and methods used across different
/// chat completion client implementations
protocol ChatCompletionClientTestSuite {
    /// The default prompt to use for chat completion tests
    var defaultPrompt: String { get }

    /// The maximum number of tokens allowed in a chat completion
    var maxTokens: Int { get }

    /// Creates a chat completion using the configured client
    /// - Parameter query: The chat completion request parameters
    /// - Returns: The generated chat completion result
    /// - Throws: Any errors that occur during the chat completion process
    public func createChat(app: Application, query: ChatCompletionContent) async throws -> ChatCompletionResult
}

extension ChatCompletionClientTestSuite {
    /// The default prompt to use for chat completion tests
    var defaultPrompt: String {
        "Hello, world!"
    }

    /// The maximum number of tokens allowed in a chat completion
    var maxTokens: Int {
        100
    }

    /// Helper function to create and manage a test application instance
    /// Creates a test application, runs the provided test closure, and ensures proper cleanup
    ///
    /// - Parameter test: The test closure to execute with the application instance
    /// - Throws: Any errors that occur during test execution, including:
    ///   - Application initialization errors
    ///   - Test execution errors
    ///   - Shutdown errors
    public func withApp(test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    /// Default implementation for creating a chat completion
    /// Note: This implementation requires the 'app' parameter to be in scope
    ///
    /// - Parameter query: The chat completion request parameters
    /// - Returns: The generated chat completion result
    /// - Throws: Any errors that occur during the chat completion process, including:
    ///   - Client initialization errors
    ///   - Network errors
    ///   - Invalid response formats
    public func createChat(app: Application, query: ChatCompletionContent) async throws -> ChatCompletionResult {
        let client = ChatCompletionClient(logger: app.logger)

        let queryWithMaxTokens: ChatCompletionContent = .init(
            model: query.model,
            prompt: query.prompt,
            maxTokens: maxTokens
        )

        return try await client.createChat(queryWithMaxTokens)
    }
}
