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

    init() throws {
        client = try .init(apiToken: Environment.getOrThrow("OPENAI_API_KEY"))
    }

    func createImage(_ query: ImagesQuery) async throws -> ImagesResult {
        try await client.images(query: query)
    }
}
