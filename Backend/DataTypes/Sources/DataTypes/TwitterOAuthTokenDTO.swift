// TwitterOAuthTokenDTO.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public struct TwitterOAuthTokenDTO: Content {
    public var id: UUID?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?
    public let oauthToken: String
    public let oauthTokenSecret: String
    public let oauthCallbackConfirmed: Bool?
    public let userID: UUID?

    public init(
        id: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil,
        oauthToken: String,
        oauthTokenSecret: String,
        oauthCallbackConfirmed: Bool? = nil,
        userID: UUID? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.oauthToken = oauthToken
        self.oauthTokenSecret = oauthTokenSecret
        self.oauthCallbackConfirmed = oauthCallbackConfirmed
        self.userID = userID
    }
}
