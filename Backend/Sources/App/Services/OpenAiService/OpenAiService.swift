// OpenAiService.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import OpenAI
import Vapor

enum OpenAiErrors: Error {
    case missingImage
}

struct OpenAiService {
    let client: OpenAI
    let logger: Logger

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
        try await client.images(query: query)
    }
}
