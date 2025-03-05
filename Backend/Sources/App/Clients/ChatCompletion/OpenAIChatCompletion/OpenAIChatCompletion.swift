// OpenAIChatCompletion.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import OpenAI
import Vapor

@unchecked Sendable
extension ChatQuery: Content {}

struct OpenAIChatCompletion {
    private let client: OpenAI
    private let logger: Logger

    init(logger: Logger, timeout: TimeInterval = 180) throws {
        client = try .init(
            configuration: .init(
                token: Environment.getOrThrow("OPENAI_API_KEY"),
                timeoutInterval: timeout
            )
        )
        self.logger = logger
    }

    func createChat(_ query: ChatQuery) async throws -> ChatResult {
        BackendMetric.openaiChatGenerationRequests.increment()
        let result = try await client.chats(query: query)
        return result
    }
}
