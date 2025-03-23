// OpenAIChatCompletionClientTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Fluent
import Testing
import VaporTesting

@Suite("OpenAI Chat Completion Client Tests")
struct OpenAIChatCompletionClientTests {
    private func withApp(test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Generate Chat Completion Result Success")
    func generateChatCompletionResultSuccess() async throws {
        try await withApp { app in
            let client = try OpenAIChatCompletionClient(logger: app.logger)
            let result = try await client.createChat(.init(model: .gpt4o, prompt: "Hello, how are you?"))
            let message = result.message

            app.logger.info(
                "Generated chat completion result success.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "message": .string(message),
                ]
            )

            #expect(message.count > 5, "Generated message should have more than 5 characters")
        }
    }
}
