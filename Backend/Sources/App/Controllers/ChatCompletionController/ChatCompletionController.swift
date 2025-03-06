// ChatCompletionController.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import OpenAI
import Vapor

struct ChatCompletionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let chatCompletionRoute = routes.grouped("ChatCompletion")

        chatCompletionRoute.post("openai", use: openai)
    }

    @Sendable
    func openai(req: Request) async throws -> String {
        let openaiClient = try OpenAIChatCompletion(logger: req.logger)
        let query = try req.content.decode(ChatCompletionContent.self)
        let result = try await openaiClient.createChat(query)

        guard
            let message = result.choices.first?.message.content?.string
        else {
            let errorCodeWhenMessageNotFound = 500
            throw Abort(.internalServerError)
        }

        return message
    }
}
