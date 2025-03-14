// RssFeedItemDTO.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public struct RssFeedItemDTO: Content {
    public var id: UUID?
    public var rssFeedId: UUID
    public var content: String
    public var link: String
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?

    public init(
        id: UUID?,
        rssFeedId: UUID,
        content: String,
        link: String,
        createdAt: Date?,
        updatedAt: Date?,
        deletedAt: Date?
    ) {
        self.id = id
        self.rssFeedId = rssFeedId
        self.content = content
        self.link = link
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}
