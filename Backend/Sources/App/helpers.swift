// helpers.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

extension Environment {
    static func getOrThrow(_ key: String) throws -> String {
        guard let value = Environment.get(key) else {
            throw Abort(.notFound, reason: "Value for key \(key) not found")
        }

        return value
    }
}
