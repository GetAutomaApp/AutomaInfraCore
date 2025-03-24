// ImageGenerationClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation
import OpenAI
import Vapor

protocol ImageGenerationClientBase {
    var logger: Logger { get }
    func generateImage(_ query: GenerateImageQuery) async throws -> GenerateImageResult
}

struct GenerateImageQuery: Content {
    let model: GenerateImageModel
    let prompt: String
    let totalImagesToGenerate: Int?
    let quality: GenerateImageQuality?
    let imageSize: GenerateImageSize?
    let imageStyle: GenerateImageStyle?
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

enum GenerateImageQuality: String, Codable {
    case standard
    case hd
}

public enum GenerateImageSize: String, Codable, Sendable {
    case _256 = "256x256"
    case _512 = "512x512"
    case _1024 = "1024x1024"
    case _1792_1024 = "1792x1024" // for dall-e-3 models
    case _1024_1792 = "1024x1792" // for dall-e-3 models
}

public enum GenerateImageStyle: String, Codable, Sendable {
    case natural
    case vivid
}
