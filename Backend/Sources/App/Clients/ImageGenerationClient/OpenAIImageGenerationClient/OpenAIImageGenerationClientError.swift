// OpenAIImageGenerationClientError.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

enum OpenAIImageGenerationClientError: Error {
    case invalidModel
    case responseError
    case encodeError((any Error)?)
    case generationError((any Error)? = nil)
}
