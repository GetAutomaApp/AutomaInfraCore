// DataExtensions.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public extension Data {
    func decodeAsJSON<T: Content>(type: T.Type) throws -> T {
        try JSONDecoder().decode(type.self, from: self)
    }
}
