// OpenAIChatCompletionClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import OpenAI
import Vapor

/// Client for interacting with OpenAI's chat completion API
/// Handles authentication, request configuration, and response processing for chat completions
struct OpenAIChatCompletionClient: ChatCompletion {
    /// The underlying OpenAI API client
    private let client: OpenAI
    
    /// Logger instance for tracking operations and errors
    let logger: Logger
    
    /// API key for authenticating with OpenAI services
    private let apiKey: String

    /// Initializes a new OpenAI chat completion client
    /// - Parameters:
    ///   - logger: Logger instance for tracking operations
    ///   - timeout: Maximum time to wait for API responses in seconds (default: 180)
    ///   - apiKey: Optional API key override. If nil, reads from environment
    /// - Throws: Environment error if API key cannot be retrieved
    init(logger: Logger, timeout: TimeInterval = 180, apiKey: String? = nil) throws {
        self.apiKey = try apiKey ?? Environment.getOrThrow("OPENAI_API_KEY")
        client = .init(
            configuration: .init(
                token: self.apiKey,
                timeoutInterval: timeout
            )
        )
        self.logger = logger
    }

    /// Creates a chat completion using the OpenAI API
    /// - Parameter query: The chat completion request parameters
    /// - Returns: The generated chat completion result
    /// - Throws: ChatCompletionClientError if the request fails or returns invalid data
    func createChat(_ query: ChatCompletionContent) async throws -> ChatCompletionResult {
        let model = query.model
        let result: ChatResult
        let prompt = query.prompt

        do {
            result = try await client.chats(
                query: .init(
                    messages: [
                        .init(role: .system, content: prompt)!,
                    ],
                    model: model.rawValue
                )
            )
        } catch {
            BackendMetric.chatCompletionServiceCall(platform: .openai, model: model, status: .fail).increment()
            logger.error(
                "Failed to generate chat completion, error: \(error)",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "model": .string(model.rawValue),
                    "query": .string(prompt),
                ]
            )
            throw ChatCompletionClientError.completionError
        }

        guard
            let usage = result.usage
        else {
            logger.error(
                "Unable to get usage from chat completion result.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                ]
            )
            throw ChatCompletionClientError.completionError
        }

        logger.info(
            "OpenAI chat completions result metadata",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "usage": .string("\(usage)"),
            ]
        )

        guard let message = result.choices.first?.message.content?.string else {
            BackendMetric.chatCompletionServiceCall(platform: .openai, model: model, status: .fail).increment()
            logger.error(
                "Failed to generate chat completion, message empty",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "model": .string(model.rawValue),
                    "query": .string(prompt),
                    "resultObject": .string(result.object),
                ]
            )
            throw ChatCompletionClientError.completionMessageEmpty
        }

        BackendMetric.chatCompletionServiceCall(platform: .openai, model: model, status: .success).increment()
        let metadata = try JSONEncoder().encode(result)
        logger.info(
            "OpenAI chat completions result metadata",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "metadata": .string(String(describing: metadata)),
            ]
        )

        return .init(message: message, metadata: metadata)
    }
}
