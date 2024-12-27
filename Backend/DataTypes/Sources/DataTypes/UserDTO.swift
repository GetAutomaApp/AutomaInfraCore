// UserDTO.swift
// was created on 12/27/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public struct UserDTO: Content {
    public var id: UUID?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?
    public var username: String
    public var phoneNumber: String
    public var instagramHandle: String?
    public var profilePictureKey: String?
    public var profilePictureUrl: String?

    public init(
        id: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil,
        username: String,
        phoneNumber: String,
        instagramHandle: String? = nil,
        profilePictureKey: String? = nil,
        profilePictureUrl: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.username = username
        self.phoneNumber = phoneNumber
        self.instagramHandle = instagramHandle
        self.profilePictureKey = profilePictureKey
        self.profilePictureUrl = profilePictureUrl
    }
}
