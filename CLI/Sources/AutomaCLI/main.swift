// main.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

@main
struct AutomaCLI {
    static func main() async throws {
        var env = try Environment.detect()
        let app = try await Application.make(env)

        defer { Task { try? await app.asyncShutdown() } }

        app.commands.use(GenerateAppComponent(), as: "generate")

        try await app.execute()
    }
}
