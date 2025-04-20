// ChatCompletionClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

/// Client for handling chat completion requests across different AI platforms.
/// Delegates requests to the appropriate platform-specific client based on the model.
///
/// This struct implements the `ChatCompletion` protocol and serves as a facade for various
/// AI platform-specific chat completion implementations. It dynamically selects and uses
/// the appropriate client based on the requested model.
///
/// Usage example:
/// ```swift
/// let client = ChatCompletionClient(logger: logger)
/// let result = try await client.createChat(query)
/// ```
internal struct ChatCompletionClient: ChatCompletion {
    /// Logger instance for tracking operations and errors.
    /// This logger is passed to platform-specific clients for consistent logging across the system.
    ///
    /// The logger is used to:
    /// - Track API calls and their responses
    /// - Log errors and exceptions
    /// - Monitor performance metrics
    public var logger: Logging.Logger

    /// Creates a chat completion using the appropriate platform client.
    ///
    /// This method performs the following steps:
    /// 1. Determines the appropriate platform client based on the model
    /// 2. Initializes the platform-specific client
    /// 3. Delegates the chat completion request to the selected client
    ///
    /// - Parameter query: The chat completion request parameters including model, prompt and other settings.
    ///                   This contains all necessary information to generate the completion.
    /// - Returns: The generated chat completion result containing the AI's response and any additional metadata.
    /// - Throws: Errors that may occur during:
    ///          - Platform client initialization
    ///          - Invalid model selection
    ///          - Network communication
    ///          - Chat completion generation
    public func createChat(_ query: ChatCompletionContent) async throws -> ChatCompletionResult {
        // Get the appropriate platform client based on the requested model
        let client = try query.model.getPlatformClient(logger: logger)

        // Delegate the chat completion request to the platform-specific client
        return try await client.createChat(query)
    }
}
