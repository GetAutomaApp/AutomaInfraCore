// OpenAIImageGenerationClientTests.swift
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
        do {
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
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
            let client = ImageGenerationClient(logger: app.logger)
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
                let imageB64 = image.b64Json
            else {
                try #require(Bool(false), "Generated image base64 string should not be nil")
                return
            }

            guard
                let revisedPrompt = image.revisedPrompt
            else {
                try #require(Bool(false), "Generated image revised prompt should not be nil")
                return
            }

            app.logger.info(
                "Length of base64 string generated image.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "length": .string(String(imageB64.count)),
                ]
            )

            app.logger.info(
                "Revised prompt of generated image.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "prompt": .string(revisedPrompt),
                ]
            )
        }
    }
}
