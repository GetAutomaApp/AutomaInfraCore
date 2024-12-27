// helpers.swift
// was created on 12/27/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public extension Content {
    func encodeToDictionary() throws -> [String: any Sendable] {
        // TODO: Fix this up
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: any Sendable]
        else {
            throw Abort(.internalServerError, reason: "Failed to convert DTO to dictionary")
        }
        return dictionary
    }

    static func decodeJSONFromData(data: Data?) throws -> Self {
        // TODO: Fix this up
        guard let data else { throw Abort(.badRequest, reason: "Missing JSON data") }

        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}
