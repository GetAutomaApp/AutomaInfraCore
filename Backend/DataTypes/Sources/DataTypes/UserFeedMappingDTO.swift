// UserFeedMappingDTO.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public struct UserFeedMappingDTO: Content {
    public var id: UUID
    public var feedId: UUID
    public var userId: UUID
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?

    public init(id: UUID, feedId: UUID, userId: UUID, createdAt: Date, updatedAt: Date, deletedAt: Date?) {
        self.id = id
        self.userId = userId
        self.feedId = feedId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}
