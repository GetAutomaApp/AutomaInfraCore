// entrypoint.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

/// The main entry point for the CLI application.
@main
internal enum Entrypoint {
    /// The main function that sets up and runs the application.
    static func main() async throws {
        // Detect the environment and create an application instance
        let env = try Environment.detect()
        let app = try await Application.make(env)

        // Ensure the application is properly shut down on exit
        defer { Task { try? await app.asyncShutdown() } }

        // Register commands with the application
        app.commands.use(GenerateAppComponent(), as: "generate")
        app.commands.use(FlyConfigGenerator(), as: "fly-config")

        // Execute the application
        try await app.execute()
    }
}
