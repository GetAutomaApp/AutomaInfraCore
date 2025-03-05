// ChatCompletionController.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

struct AnthropicController: RouteCollection {
    let anthropicAPIKey = Environment.get("ANTHROPIC_API_KEY")

    func boot(routes: RoutesBuilder) throws {
        let chatCompletionRoute = routes.grouped("ChatCompletion")
        chatCompletionRoute.post("anthropic", use: anthropic)
        chatCompletionRoute.get("test", use: test)
    }

    @Sendable
    func anthropic(req: Request) async throws -> String {
        // let client = AnthropicClient(apiKey: anthropicAPIKey)
        let client = AnthropicClient()
        let body = try req.content.decode(AnthropicChatCompletionRequest.self)
        // return client.chatCompletion(prompt: String, model: Model, maxTokensToSample: Int)
        return try await client.chatCompletion(prompt: body.prompt)
    }

    @Sendable
    func test(req _: Request) async throws -> String {
        "Hello, World!"
    }
}
