// OpenAiService.swift
// was created on 12/26/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import OpenAI
import Vapor

struct OpenAiService {
    let client: OpenAI

    init(timeout: TimeInterval = 180) throws {
        client = try .init(
            configuration: .init(
                token: Environment.getOrThrow("OPENAI_API_KEY"),
                timeoutInterval: timeout
            )
        )
    }

    func createImage(_ query: ImagesQuery) async throws -> ImagesResult {
        try await client.images(query: query)
    }
}
