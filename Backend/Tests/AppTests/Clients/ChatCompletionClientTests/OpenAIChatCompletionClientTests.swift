// OpenAIChatCompletionClientTests.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import App
import Fluent
import Testing
import Vapor
import VaporTesting

@Suite("OpenAI Chat Completion Client Tests")
struct OpenAIChatCompletionClientTests {
    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await test(app)
        } catch {
            app.logger.error(
                "Failed to create app for suite 'OpenAIChatCompletionClientTests'",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(String(String(reflecting: error))),
                ]
            )
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    // TODO: Create a test to check if it throws no API key found in environment

    @Test("Handle unsupported model in chat completion") func handleUnsupportedModel() async throws {
        try await withApp { app in
            let model = ChatCompletionModel.llama3

            let client = try OpenAIChatCompletionClient(logger: app.logger)
            #expect(throws: ChatCompletionClientError.invalidModel, "Unsupported model should throw an error") {
                try client.validateModel(model: model)
            }
        }
    }
}
