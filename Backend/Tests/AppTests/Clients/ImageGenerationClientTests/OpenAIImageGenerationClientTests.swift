// OpenAIImageGenerationClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Fluent
import OpenAI
import Testing
import VaporTesting

@Suite("OpenAI Image Generation Client Tests")
struct OpenAIImageGenerationClientTests {
    private func withApp(test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        try await test(app)
        try await app.asyncShutdown()
    }

    // TODO: Create tests for the following scenarios
    // - Generate Image Result Success (dalle3)
    // - Generate Image Result Success (dalle2)
    // - Generate Image Result Fail (dalle2 with resolution of dalle3)

    // TODO: add input prompts for the following test
    @Test("Generate Image Result Success")
    func generateImageResultSuccess() async throws {
        try await withApp { app in
            let client = try ImageGenerationClient(logger: app.logger)
            let query: GenerateImageQuery = .init(
                model: .dall_e_3,
                totalImagesToGenerate: 1,
                prompt: "A fluffy golden retriever puppy playing in a sunny meadow filled with colorful wildflowers.",
                quality: .hd,
                imageSize: ._1024_1792,
                imageStyle: .vivid
            )
            let result = try await client.generateImage(query)

            let imagesResult = try JSONDecoder().decode(ImagesResult.self, from: result.metadataJSON)
            let image = imagesResult.data[0]

            guard
                let url = image.url
            else {
                #require(Bool(false), "Generated image URL should not be nil")
            }

            guard
                let revisedPrompt = image.revisedPrompt
            else {
                #require(Bool(false), "Generated image revised prompt should not be nil")
            }

            app.logger.info(
                "URL of generated image.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "url": .string(url),
                ]
            )

            app.logger.info(
                "Revised prompt of generated image.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "url": .string(revisedPrompt),
                ]
            )
        }
    }
}
