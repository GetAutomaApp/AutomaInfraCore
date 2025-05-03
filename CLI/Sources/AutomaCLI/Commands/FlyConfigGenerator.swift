// FlyConfigGenerator.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

/// Enum representing the different Fly environments.
private enum FlyEnvironments: String, CaseIterable {
    case production
    case sandbox
    case staging
}

/// Command to generate a fly.io config file from the input config and environment type.
public struct FlyConfigGenerator: Command {
    /// Provides help text for the command.
    public var help: String {
        "Generates a fly.io config file from the input config & environment type"
    }

    /// Signature for the command, defining the arguments and options.
    public struct Signature: CommandSignature {
        public init() {}

        /// The path of the fly.io config file.
        @Argument(name: "config-path", help: "The path of the fly.io config file")
        public var configPath: String

        /// The environment type to generate the config for.
        @Argument(
            name: "environment",
            help: "The environment type to generate the config for. `FlyEnvironments`"
        )
        public var environment: String
    }

    /// Executes the command with the given context and signature.
    /// - Parameters:
    ///   - context: The context in which the command is executed.
    ///   - signature: The command's signature containing arguments.
    /// - Throws: Any errors that occur during command execution.
    public func run(using _: CommandContext, signature: Signature) throws {
        let configPath = signature.configPath
        let environment = signature.environment

        // Check if the config file exists
        guard FileManager.default.fileExists(atPath: configPath) else {
            throw Abort(.notFound, reason: "Config file not found: \(configPath)")
        }

        // Validate the environment argument
        guard let environment = FlyEnvironments(rawValue: environment) else {
            throw Abort(.notFound, reason: "Invalid environment: \(environment)")
        }

        // Read the content of the config file
        var content = try String(contentsOfFile: configPath, encoding: .utf8)

        // Retrieve the Fly metrics token from the environment
        guard
            let metricsToken = Environment.get("FLY_METRICS_TOKEN")
        else {
            throw Abort(.notFound, reason: "FLY_METRICS_TOKEN not found in environment")
        }

        // Replace placeholders in the config content
        content = content
            .replacingOccurrences(
                of: "__FLY_ENVIRONMENT__",
                with: environment.rawValue
            )
            .replacingOccurrences(
                of: "__FLY_METRICS_TOKEN__",
                with: metricsToken
            )

        // Generate a new file path for the modified config
        let newFileUUID = UUID().uuidString
        let newFilePath = "/tmp/\(newFileUUID)-fly.toml"

        // Write the modified content to the new file
        try content.write(to: URL(fileURLWithPath: newFilePath), atomically: true, encoding: .utf8)

        // Print the path of the new config file
        print("\(newFilePath)")
    }
}
