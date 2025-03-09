// ChatCompletionClient.swift
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
