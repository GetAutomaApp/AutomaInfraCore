// entrypoint.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Logging
import Metrics
import NIOCore
import NIOPosix
import Vapor

/// The main entry point for the application.
@main
internal enum Entrypoint {
    /// The main function that initializes and runs the application.
    /// - Throws: Throws an error if the application fails to start or execute.
    static func main() async throws {
        // Detect the current environment configuration
        var env = try Environment.detect()

        // Set up the logging system based on the environment
        try LoggingSystem.bootstrap(from: &env)

        // Create a new application instance with the detected environment
        let app = try await Application.make(env)

        // This attempts to install NIO as the Swift Concurrency global executor.
        // You can enable it if you'd like to reduce the amount of context switching between NIO and Swift Concurrency.
        // Note: this has caused issues with some libraries that use `.wait()` and cleanly shutting down.
        // If enabled, you should be careful about calling async functions before this point as it can cause assertion
        // failures.
        // let executorTakeoverSuccess =
        // NIOSingletons.unsafeTryInstallSingletonPosixEventLoopGroupAsConcurrencyGlobalExecutor()
        // app.logger.debug("Tried to install SwiftNIO's EventLoopGroup as Swift's global concurrency executor",
        // metadata:
        // ["success": .stringConvertible(executorTakeoverSuccess)])

        do {
            // Configure the application
            try await configure(app)
        } catch {
            // Report any errors that occur during configuration
            app.logger.report(error: error)
            // Attempt to shut down the application gracefully
            try? await app.asyncShutdown()
            // Rethrow the error to indicate failure
            throw error
        }

        // Execute the application
        try await app.execute()
        // Shut down the application after execution
        try await app.asyncShutdown()
    }
}
