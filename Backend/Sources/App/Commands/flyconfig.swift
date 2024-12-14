// flyconfig.swift
// was created on 12/14/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

enum FlyEnvironments: String, CaseIterable {
    case sandbox
    case staging
    case production
}

struct FlyConfigGenerator: Command {
    var help: String {
        "Generates a fly.io config file from the input config & environment type"
    }

    struct Signature: CommandSignature {
        @Argument(name: "config-path", help: "The path of the fly.io config file")
        var configPath: String

        @Argument(
            name: "environment",
            help: "The environment type to generate the config for. `FlyEnvironments`"
        )
        var environment: String
    }

    func run(using _: CommandContext, signature: Signature) throws {
        let configPath = signature.configPath
        let environment = signature.environment

        guard FileManager.default.fileExists(atPath: configPath) else {
            throw Abort(.notFound, reason: "Config file not found: \(configPath)")
        }

        guard let environment = FlyEnvironments(rawValue: environment) else {
            throw Abort(.notFound, reason: "Invalid environment: \(environment)")
        }

        var content = try String(contentsOfFile: configPath)

        content = content
            .replacingOccurrences(
                of: "__FLY_ENVIRONMENT__",
                with: environment.rawValue
            )

        let newFileUUID = UUID().uuidString
        let newFilePath = "/tmp/\(newFileUUID)-fly.toml"

        try content.write(to: URL(fileURLWithPath: newFilePath), atomically: true, encoding: .utf8)

        print("\(newFilePath)")
    }
}
