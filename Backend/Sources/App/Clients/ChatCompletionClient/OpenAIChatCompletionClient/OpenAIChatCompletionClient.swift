// OpenAIChatCompletionClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import OpenAI
import Vapor

struct OpenAIChatCompletionClient: ChatCompletion {
    private let client: OpenAI
    let logger: Logger
    private let apiKey: String

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

    func createChat(_ query: ChatCompletionContent) async throws -> ChatCompletionResult {
        let model = query.model
        let result: ChatResult
        do {
            result = try await client.chats(
                query: .init(
                    messages: [
                        .init(role: .system, content: query.prompt)!,
                    ],
                    model: model.rawValue
                )
            )
        } catch {
            BackendMetric.chatCompletionServiceCall(platform: .openai, model: model, status: .fail).increment()
            logger.error("Failed to generate chat completion, error: \(error)")
            throw ChatCompletionClientError.completionError
        }

        guard let message = result.choices.first?.message.content?.string else {
            BackendMetric.chatCompletionServiceCall(platform: .openai, model: model, status: .fail).increment()
            logger.error("Failed to generate chat completion, message empty")
            throw ChatCompletionClientError.completionMessageEmpty
        }

        BackendMetric.chatCompletionServiceCall(platform: .openai, model: model, status: .success).increment()
        return .init(message: message)
    }
}
