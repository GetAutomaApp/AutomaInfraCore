// ImageGenerationClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import OpenAI

struct ImageGenerationClient: ImageGenerationClientBase {
    func generateImage(_ query: GenerateImageQuery) async throws -> GenerateImageResult {
        let model = query.model
    }
}
