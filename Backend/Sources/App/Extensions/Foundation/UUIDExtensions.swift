// UUIDExtensions.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

/// unwrap uuid from string & calls specific callback if error occurs
public extension UUID {
    /// unwrap uuid from string & calls specific callback if error occurs
    public static func unwrapFromString(_ uuidString: String, _ callback: () throws -> Void) throws -> UUID {
        guard
            let uuid = UUID(uuidString: uuidString)
        else {
            try callback()
            throw Abort(.internalServerError)
        }
        return uuid
    }
}
