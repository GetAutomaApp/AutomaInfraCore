// ChatCompletionClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

/// Client for handling chat completion requests across different AI platforms
/// Delegates requests to the appropriate platform-specific client based on the model
internal struct ChatCompletionClient: ChatCompletion {
    /// Logger instance for tracking operations and errors
    var logger: Logging.Logger

    /// Creates a chat completion using the appropriate platform client
    /// - Parameter query: The chat completion request parameters including model, prompt and other settings
    /// - Returns: The generated chat completion result
    /// - Throws: Errors from platform client initialization or chat completion generation
    func createChat(_ query: ChatCompletionContent) async throws -> ChatCompletionResult {
        let client = try query.model.getPlatformClient(logger: logger)
        return try await client.createChat(query)
    }
}
