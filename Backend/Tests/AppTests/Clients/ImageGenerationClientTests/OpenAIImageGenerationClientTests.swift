// OpenAIImageGenerationClientTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Fluent
import OpenAI
import Testing
import VaporTesting

/// Tests for the OpenAI Image Generation Client implementation
/// These tests verify the functionality of image generation using both DALL-E 2 and DALL-E 3 models
@Suite("OpenAI Image Generation Client Tests")
struct OpenAIImageGenerationClientTests: ImageGenerationClientTestSuite {
    /// Tests that using DALL-E 2 with a DALL-E 3 specific resolution fails appropriately
    @Test("Generate Image Result Fail (dalle2 with resolution of dalle3)")
    func generateImageResultFailDalle2() async throws {
        try await withApp { app in
            await #expect(
                throws: OpenAIImageGenerationClientError.self,
                "Should throw OpenAIImageGenerationClientError when using DALL-E 2 with DALL-E 3 resolution"
            ) {
                try await generateImage(
                    app: app,
                    query: .init(
                        model: .dall_e_2,
                        prompt: defaultPrompt,
                        totalImagesToGenerate: 1,
                        quality: .hd,
                        imageSize: ._1792_1024,
                        imageStyle: .vivid
                    )
                )
            }
        }
    }

    /// Tests successful image generation using DALL-E 2
    /// Verifies that the client can generate images and return valid base64-encoded results
    @Test("Generate Image Result Success (dalle2)")
    func generateImageResultSuccessDalle2() async throws {
        try await withApp { app in
            let result = try await generateImage(
                app: app,
                query: .init(
                    model: .dall_e_2,
                    prompt: defaultPrompt,
                    totalImagesToGenerate: 1,
                    quality: .hd,
                    imageSize: ._1024,
                    imageStyle: .vivid
                )
            )

            let imagesResult = try JSONDecoder().decode(ImagesResult.self, from: result.metadataJSON)
            let image = imagesResult.data[0]

            try #require(image.b64Json != nil, "Generated image base64 string should not be nil")
            return
        }
    }

    /// Tests successful image generation using DALL-E 3
    /// Verifies that the client can generate images with DALL-E 3 specific parameters
    @Test("Generate Image Result Success (dalle3)")
    func generateImageResultSuccessDalle3() async throws {
        try await withApp { app in
            let client = ImageGenerationClient(logger: app.logger)
            let query: GenerateImageQuery = .init(
                model: .dall_e_3,
                prompt: defaultPrompt,
                totalImagesToGenerate: 1,
                quality: .hd,
                imageSize: ._1024_1792,
                imageStyle: .vivid
            )
            let result = try await client.generateImage(query)

            let imagesResult = try JSONDecoder().decode(ImagesResult.self, from: result.metadataJSON)
            let image = imagesResult.data[0]

            try #require(image.b64Json != nil, "Generated image base64 string should not be nil")
            return
        }
    }
}
