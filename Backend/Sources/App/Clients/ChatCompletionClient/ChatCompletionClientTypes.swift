// ChatCompletionClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

struct ChatCompletionContent: Content {
    let model: ChatCompletionModel
    let prompt: String
}

enum ChatCompletionModel: String, Codable {
    case gpt4o = "gpt-4o"
    case gpt4omini = "gpt-4o-mini"
    case gpto1 = "o1"
}

enum ChatCompletionPlatform: String, Codable {
    case openai
}

struct ChatCompletionResult: Content {
    let message: String
}
