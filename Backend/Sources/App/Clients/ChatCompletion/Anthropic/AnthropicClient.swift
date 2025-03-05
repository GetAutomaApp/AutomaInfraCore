// AnthropicClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftAnthropic

class AnthropicClient {
    // private let service: AnthropicService

    // init(apiKey: String) {
    init() {
        service = AnthropicServiceFactory.service(apiKey: "test")
    }

    // func chatCompletion(prompt: String, model: Model, maxTokensToSample: Int) async throws -> String
    func chatCompletion(prompt _: String) async throws -> String {
        // let parameters = TextCompletionParameter(
        //     model: model, prompt: prompt, maxTokensToSample: maxTokensToSample)
        // let textCompletion = try await service.createTextCompletion(parameters)
        // return textCompletion.completion
        "bob"
    }
}
