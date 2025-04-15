// entrypoint.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

@main
internal enum Entrypoint {
    static func main() async throws {
        let env = try Environment.detect()
        let app = try await Application.make(env)

        defer { Task { try? await app.asyncShutdown() } }

        app.commands.use(GenerateAppComponent(), as: "generate")
        app.commands.use(FlyConfigGenerator(), as: "fly-config")

        try await app.execute()
    }
}
