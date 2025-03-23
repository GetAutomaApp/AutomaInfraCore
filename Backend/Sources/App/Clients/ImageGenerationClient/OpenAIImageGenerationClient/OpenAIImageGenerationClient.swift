// OpenAIImageGenerationClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation
import OpenAI
import Vapor

/// A client for generating images using OpenAI's API.
struct OpenAIImageGenerationClient: ImageGenerationClientBase {
    private let client: OpenAI
    let logger: Logger

    init(logger: Logger, timeout: TimeInterval = 180) throws {
        let token = try Environment.getOrThrow("OPENAI_API_KEY")
        client = .init(
            configuration: .init(
                token: token,
                timeoutInterval: timeout
            )
        )
        self.logger = logger
    }

    func generateImage(_ query: GenerateImageQuery) async throws -> GenerateImageResult {
        BackendMetric.openAIImageGenerationRequests.increment()

        let result = try await client.images(query: .init(
            prompt: query.prompt,
            model: getModel(from: query.model),
            n: query.totalImagesToGenerate,
            quality: .init(rawValue: query.quality.rawValue),
            responseFormat: .b64_json,
            size: .init(rawValue: query.imageSize.rawValue),
            style: .init(rawValue: query.imageStyle.rawValue)
        ))

        logger.info(
            "Successfully generated response.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "response": .string("\(result)"),
            ]
        )

        return try .init(
            images: result.data.map { image in
                guard
                    let imageB64String = image.b64Json,
                    let data = Data(base64Encoded: imageB64String)
                else {
                    throw OpenAIImageGenerationClientError.responseError
                }
                return data
            },
            metadataJSON: JSONEncoder().encode(result)
        )
    }

    private func getModel(from model: GenerateImageModel) throws -> Model {
        switch model {
        case .dall_e_2:
            .dall_e_2
        case .dall_e_3:
            .dall_e_3
        }
    }
}
