// OpenAIImageGenerationClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Fluent
import Testing
import VaporTesting

@Suite("OpenAI Image Generation Client Tests")
struct OpenAIImageGenerationClient {
    private func withApp(test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        try await test(app)
        try await app.asyncShutdown()
    }

    @Test("Generate Image Result Success")
    func generateImageResultSuccess() async throws {
        try await withApp { app in
            let client = try ImageGenerationClient(logger: app.logger)
            let result = try await client.generateImage()
            let message = result.message
        }
    }
}
