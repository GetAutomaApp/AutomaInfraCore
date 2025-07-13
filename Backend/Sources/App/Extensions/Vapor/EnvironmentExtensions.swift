// EnvironmentExtensions.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

/// Extension to throw error if we can't find an env value
public extension Environment {
    /// Extension to throw error if we can't find an env value
    public static func getOrThrow(_ key: String) throws -> String {
        guard let value = Environment.get(key) else {
            throw Abort(.notFound, reason: "Value for key \(key) not found")
        }

        return value
    }
}
