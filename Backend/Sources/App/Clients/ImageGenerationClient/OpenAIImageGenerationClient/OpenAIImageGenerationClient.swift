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
        BackendMetric.openAIImageGenerationRequest(status: .start).increment()

        let imageSize = query.imageSize?.rawValue
        let quality = query.quality?.rawValue
        let style = query.imageStyle?.rawValue

        let queryForImageGeneration: ImagesQuery = try .init(
            prompt: query.prompt,
            model: getModel(from: query.model),
            n: query.totalImagesToGenerate,
            quality: quality != nil ? .init(rawValue: quality!) : nil,
            responseFormat: .b64_json,
            size: imageSize != nil ? .init(rawValue: imageSize!) : nil,
            style: style != nil ? .init(rawValue: style!) : nil
        )
        let result: ImagesResult
        do {
            result = try await client.images(query: queryForImageGeneration)
        } catch {
            BackendMetric.openAIImageGenerationRequest(status: .fail).increment()
            logger.error(
                "Failed to generate image",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(String(reflecting: error)),
                    "query": .string(String(reflecting: query)),
                    "queryForImageGeneration": .string(String(reflecting: queryForImageGeneration)),
                ]
            )
            throw OpenAIImageGenerationClientError.generationError(error)
        }

        logger.info(
            "Successfully generated response.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
            ]
        )

        let resultData: Data
        let images: [Data]

        do {
            resultData = try JSONEncoder().encode(result)
            images = try result.data.map { image in
                guard
                    let imageB64String = image.b64Json,
                    let data = Data(base64Encoded: imageB64String)
                else {
                    throw OpenAIImageGenerationClientError.responseError
                }
                return data
            }
        } catch {
            BackendMetric.openAIImageGenerationRequest(status: .fail).increment()
            logger.error(
                "Failed to encode result or images response.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(String(reflecting: error)),
                ]
            )
            throw OpenAIImageGenerationClientError.encodeError(error)
        }

        BackendMetric.openAIImageGenerationRequest(status: .success).increment()

        return .init(
            images: images,
            metadataJSON: resultData
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
