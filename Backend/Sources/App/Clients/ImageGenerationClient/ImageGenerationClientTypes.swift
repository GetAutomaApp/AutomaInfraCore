// ImageGenerationClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation
import OpenAI
import Vapor

protocol ImageGenerationClientBase {
    public var logger: Logger { get }
    public func generateImage(_ query: GenerateImageQuery) async throws -> GenerateImageResult
}

internal struct GenerateImageQuery: Content {
    public let model: GenerateImageModel
    public let prompt: String
    public let totalImagesToGenerate: Int?
    public let quality: GenerateImageQuality?
    public let imageSize: GenerateImageSize?
    public let imageStyle: GenerateImageStyle?

    init(
        model: GenerateImageModel,
        prompt: String,
        totalImagesToGenerate: Int? = nil,
        quality: GenerateImageQuality? = nil,
        imageSize: GenerateImageSize? = nil,
        imageStyle: GenerateImageStyle? = nil
    ) {
        self.model = model
        self.prompt = prompt
        self.totalImagesToGenerate = totalImagesToGenerate
        self.quality = quality
        self.imageSize = imageSize
        self.imageStyle = imageStyle
    }
}

internal enum GenerateImageModel: String, Codable {
    /// https://platform.openai.com/docs/models/dall-e-2
    case dall_e_2 = "dall-e-2"

    /// https://platform.openai.com/docs/models/dall-e-3
    case dall_e_3 = "dall-e-3"

    public func getPlatformClient(logger: Logger) throws -> any ImageGenerationClientBase {
        switch self {
        case .dall_e_2, .dall_e_3:
            try OpenAIImageGenerationClient(logger: logger)
        }
    }
}

internal struct GenerateImageResult: Content {
    public let images: [Data]
    public let metadataJSON: Data
}

internal enum GenerateImageQuality: String, Codable {
    case hd
    case standard
}

public enum GenerateImageSize: String, Codable, Sendable {
    case _1024 = "1024x1024"
    case _1024_1792 = "1024x1792" // for dall-e-3 models
    case _1792_1024 = "1792x1024" // for dall-e-3 models
    case _256 = "256x256"
    case _512 = "512x512"
}

public enum GenerateImageStyle: String, Codable, Sendable {
    case natural
    case vivid
}
