// ImageGenerationClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation
import OpenAI
import Vapor

protocol ImageGenerationClientBase {
    func generateImage(_ query: GenerateImageQuery) async throws -> GenerateImageResult
}

struct GenerateImageQuery: Content {
    let model: GenerateImageModel
    let totalImagesToGenerate: Int?
    let prompt: String
}

enum GenerateImageModel: String, Codable {
    case dall_e_2 = "dall-e-2"
    case dall_e_3 = "dall-e-3"

    func getPlatformClient(logger: Logger) throws -> any ImageGenerationClientBase {
        switch self {
        case .dall_e_2, .dall_e_3:
            try OpenAIImageGenerationClient(logger: logger)
        }
    }
}

struct GenerateImageResult: Content {
    let images: [Data]
    let metadataJSON: Data
}
