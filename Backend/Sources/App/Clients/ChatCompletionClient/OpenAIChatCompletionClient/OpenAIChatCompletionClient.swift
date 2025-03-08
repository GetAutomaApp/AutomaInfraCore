// OpenAIChatCompletionClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import OpenAI
import Vapor

struct OpenAIChatCompletionClient: ChatCompletion {
    private let client: OpenAI
    let logger: Logger
    let supportedModels: [String] = ["gpt-4o", "gpt-4o-mini", "o1"]

    init(logger: Logger, timeout: TimeInterval = 180) throws {
        client = try .init(
            configuration: .init(
                token: Environment.getOrThrow("OPENAI_API_KEY"),
                timeoutInterval: timeout
            )
        )
        self.logger = logger
    }

    func createChat(_ query: ChatCompletionContent) async throws -> ChatCompletionResult {
        try validateModel(model: query.model)

        let result: ChatResult
        do {
            result = try await client.chats(
                query: .init(
                    messages: [
                        .init(role: .system, content: query.prompt)!,
                    ],
                    model: query.model.rawValue
                )
            )
        } catch {
            BackendMetric.chatCompletionServiceCall(.openai, query.model, .fail).increment()
            logger.error("Failed to generate chat completion, error: \(error)")
            throw Abort(.internalServerError)
        }

        guard let message = result.choices.first?.message.content?.string else {
            logger.error("Failed to generate chat completion, message empty")
            BackendMetric.chatCompletionServiceCall(.openai, query.model, .fail).increment()
            throw Abort(.internalServerError)
        }

        BackendMetric.chatCompletionServiceCall(.openai, query.model, .success).increment()
        return .init(message: message)
    }
}
