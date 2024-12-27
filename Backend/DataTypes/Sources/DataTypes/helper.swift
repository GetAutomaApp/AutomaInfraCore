// helper.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public extension Content {
    func encodeToDictionary() throws -> [String: any Sendable] {
        let data = try JSONEncoder().encode(self) // Encode to JSON
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: any Sendable]
        else {
            throw Abort(.internalServerError, reason: "Failed to convert DTO to dictionary")
        }
        return dictionary
    }

    static func decodeJSONFromData(data: Data?) throws -> Self {
        guard let data else {
            throw Abort(.badRequest, reason: "No data provided")
        }
        do {
            return try JSONDecoder().decode(Self.self, from: data)
        } catch {
            throw Abort(
                .internalServerError,
                reason: "Failed to decode JSON to \(Self.self): \(error.localizedDescription)"
            )
        }
    }
}
