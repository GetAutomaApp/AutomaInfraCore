// JwtTokenDTO.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public struct JwtTokenDTO: Content {
    public var id: UUID?
    public var token: String
    public var userId: UUID
    public var subject: JWTTokenSubject
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?

    public init(
        id: UUID? = nil,
        token: String,
        userId: UUID,
        subject: JWTTokenSubject,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.token = token
        self.userId = userId
        self.subject = subject
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}
