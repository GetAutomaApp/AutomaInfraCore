// ModelExtensions.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

public extension Model {
    static func doesExist(id: UUID, on database: any Database) async throws -> Bool {
        try await query(on: database)
            .filter("id", .equal, id)
            .count() > 0
    }
}
