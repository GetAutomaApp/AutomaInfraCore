// RSSFeedDTO.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public struct RSSFeedDTO: Content {
    public var id: UUID
    public var link: URL
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?

    public init(id: UUID, link: String, createdAt: Date, updatedAt: Date, deletedAt: Date?) throws {
        guard let link = URL(string: link) else {
            throw GenericErrors.invalidUrl
        }

        self.id = id
        self.link = link
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}
