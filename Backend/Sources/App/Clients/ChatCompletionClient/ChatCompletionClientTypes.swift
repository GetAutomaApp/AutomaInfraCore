// ChatCompletionClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

/// Protocol defining the interface for chat completion services
/// Implementations handle the specifics of interacting with different AI platforms
protocol ChatCompletion {
    /// Logger instance for tracking operations and errors
    var logger: Logger { get }

    /// Creates a chat completion using the specified query parameters
    /// - Parameter query: The chat completion request parameters
    /// - Returns: The generated chat completion result
    /// - Throws: Errors that occur during the chat completion process
    public func createChat(_ query: ChatCompletionContent) async throws -> ChatCompletionResult
}

/// Structure representing the content of a chat completion request
/// Contains all necessary parameters to generate a chat completion
internal struct ChatCompletionContent: Content {
    /// The AI model to use for generating the completion
    let model: ChatCompletionModel

    /// The prompt text to send to the AI model
    let prompt: String

    /// The maximum number of tokens to generate in the completion
    let maxTokens: Int?

    init(model: ChatCompletionModel, prompt: String, maxTokens: Int? = nil) {
        self.model = model
        self.prompt = prompt
        self.maxTokens = maxTokens
    }
}

/// Enumeration of supported chat completion models
/// Each case represents a specific AI model with its raw string value
internal enum ChatCompletionModel: String, Codable {
    /// https: // platform.openai.com/docs/models/gpt-4o
    case gpt4o = "gpt-4o"

    /// https://platform.openai.com/docs/models/gpt-4o-mini
    case gpt4omini = "gpt-4o-mini"

    /// https://platform.openai.com/docs/models/o1
    case gpto1 = "o1"

    /// Returns the appropriate platform-specific client for the selected model
    /// - Parameter logger: Logger instance to be passed to the client
    /// - Returns: A client conforming to the ChatCompletion protocol
    /// - Throws: Errors from client initialization
    public func getPlatformClient(logger: Logger) throws -> any ChatCompletion {
        switch self {
        case .gpt4o, .gpt4omini, .gpto1:
            try OpenAIChatCompletionClient(logger: logger)
        }
    }
}

/// Enumeration of supported chat completion platforms
/// Identifies the AI service provider
internal enum ChatCompletionPlatform: String, Codable {
    /// OpenAI platform (includes GPT models)
    case openai
}

/// Structure representing the result of a chat completion
/// Contains the generated message and any additional metadata
internal struct ChatCompletionResult: Content {
    /// The generated text response from the AI model
    let message: String

    /// Additional metadata about the completion
    let metadata: Data
}
