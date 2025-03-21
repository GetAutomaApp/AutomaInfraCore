// ChatCompletionClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

struct ChatCompletionClient: ChatCompletion {
    var logger: Logging.Logger

    func createChat(_ query: ChatCompletionContent) async throws -> ChatCompletionResult {
        let client = try query.model.getPlatformClient(logger: logger)
        return try await client.createChat(query)
    }
}
