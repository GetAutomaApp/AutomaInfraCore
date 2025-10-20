// EnvironmentExtensions.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

internal extension Environment {
    enum AppMode {
        case http
        case queue(name: String)
    }

    var appMode: AppMode {
        if
            CommandLine.arguments.contains("queues") ||
            CommandLine.arguments.contains("vapor-queues")
        {
            guard let name = CommandLine.arguments.firstIndex(of: "--queue") else {
                return .queue(name: "default")
            }

            return .queue(name: CommandLine.arguments[name + 1])
        } else {
            return .http
        }
    }
}
