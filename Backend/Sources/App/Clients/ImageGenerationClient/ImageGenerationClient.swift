// ImageGenerationClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import OpenAI
import Vapor

protocol ImageGenerationClient {
    func createImage(_ query: ImagesQuery) async throws -> ImagesResult
}
