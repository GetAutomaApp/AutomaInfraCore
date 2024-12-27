// AuthenticationCodeDTO.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public struct AuthenticationCodeDTO: Content {
    public var id: UUID?
    public var code: String
    public var phoneNumber: String
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?

    public init(id: UUID?, phoneNumber: String, code: String, createdAt: Date?, updatedAt: Date?, deletedAt: Date?) {
        self.id = id
        self.code = code
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}
