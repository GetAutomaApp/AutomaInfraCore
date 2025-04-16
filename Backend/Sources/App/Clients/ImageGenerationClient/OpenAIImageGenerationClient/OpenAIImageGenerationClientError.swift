// OpenAIImageGenerationClientError.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

internal enum OpenAIImageGenerationClientError: Error {
    case encodeError((any Error)?)
    case generationError((any Error)? = nil)
    case invalidModel
    case responseError
}
