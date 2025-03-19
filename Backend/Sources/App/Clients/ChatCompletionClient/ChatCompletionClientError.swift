// ChatCompletionClientError.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

enum ChatCompletionClientError: Error {
    case invalidModel
    case invalidPlatform
    case invalidPrompt
    case completionError
    case invalidMessage
}
