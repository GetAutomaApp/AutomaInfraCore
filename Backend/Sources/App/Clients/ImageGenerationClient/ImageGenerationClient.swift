// ImageGenerationClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import OpenAI
import Vapor

internal struct ImageGenerationClient: ImageGenerationClientBase {
    let logger: Logger

    func generateImage(_ query: GenerateImageQuery) async throws -> GenerateImageResult {
        let client = try query.model.getPlatformClient(logger: logger)
        let res = try await client.generateImage(query)

        guard !res.images.isEmpty else {
            logger.info(
                "No images generated.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "query": .string(String(reflecting: query)),
                ]
            )
            throw GenericErrors.missingImage
        }
        return res
    }
}
