// OpenAIImageGenerationClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import OpenAI
import Vapor

struct OpenAIImageGenerationClient: ImageGenerationClient {
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

    func createImage(_ query: ImagesQuery) async throws -> ImagesResult {
        BackendMetric.openAIImageGenerationRequests.increment()
        return try await client.images(query: query)
    }
}
