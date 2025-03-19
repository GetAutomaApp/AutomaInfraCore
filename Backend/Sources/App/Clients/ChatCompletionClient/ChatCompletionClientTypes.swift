// ChatCompletionClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

protocol ChatCompletion {
    var logger: Logger { get }
    var supportedModels: [String] { get }
    func createChat(_ query: ChatCompletionContent) async throws -> ChatCompletionResult
}

extension ChatCompletion {
    func validateModel(model: ChatCompletionModel) throws {
        guard supportedModels.contains(model.rawValue) else {
            throw Abort(.badRequest, reason: "Invalid model for OpenAI platform")
        }
    }
}

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
