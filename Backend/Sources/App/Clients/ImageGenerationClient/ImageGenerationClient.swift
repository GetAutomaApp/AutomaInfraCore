// ImageGenerationClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import OpenAI
import Vapor

/// A client for generating images using various models.
///
/// This client acts as a facade for different image generation platforms, allowing
/// the generation of images based on specified query parameters.
internal struct ImageGenerationClient: ImageGenerationClientBase {
    /// Logger instance for tracking operations and errors
    public let logger: Logger

    /// Generates images based on the provided query parameters.
    ///
    /// This function delegates the image generation task to the appropriate platform client
    /// based on the model specified in the query. It ensures that at least one image is generated
    /// and logs the operation.
    ///
    /// - Parameter query: The query containing generation parameters like prompt, model, etc.
    /// - Returns: A `GenerateImageResult` containing the generated images and metadata.
    /// - Throws: `GenericErrors.missingImage` if no images are generated.
    public func generateImage(_ query: GenerateImageQuery) async throws -> GenerateImageResult {
        // Obtain the platform-specific client based on the query's model
        let client = try query.model.getPlatformClient(logger: logger)

        // Generate images using the platform client
        let res = try await client.generateImage(query)

        // Ensure that images are generated
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

        // Return the result containing images and metadata
        return res
    }
}
