// ChatCompletionClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.
import Vapor

struct ChatCompletionClient: ChatCompletion {
    var logger: Logging.Logger

    func createChat(_ query: ChatCompletionContent) async throws -> ChatCompletionResult {
        let platform = query.model.getPlatform()
        switch platform {
        case .openai:
            let client = try OpenAIChatCompletionClient(logger: logger)
            return try await client.createChat(query)
        }
    }
}