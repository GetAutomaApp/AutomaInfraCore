// ChatCompletionController.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import OpenAI
import Vapor

struct ChatCompletionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let chatCompletionRoute = routes.grouped("ChatCompletion").grouped(
            TestControllerMiddleware()
        )

        chatCompletionRoute.post("openai", use: openai)
    }

    @Sendable
    func openai(req: Request) async throws -> String {
        let openaiClient = try OpenAIChatCompletionClient(logger: req.logger)
        let query = try req.content.decode(ChatCompletionContent.self)
        let result = try await openaiClient.createChat(query)

        return result.message
    }
}
