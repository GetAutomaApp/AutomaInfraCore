// TwitterUserTokenDTO.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

/// Access and secret access token for a Twitter account, also known as its user tokens.
/// DTO for `TwitterUserToken`
public struct TwitterUserTokenDTO: Content {
    /// Unique identifier for the Twitter user token.
    public var id: UUID?

    /// The date and time when the token was created.
    public var createdAt: Date?

    /// The date and time when the token was last updated.
    public var updatedAt: Date?

    /// The date and time when the token was deleted.
    public var deletedAt: Date?

    /// The access token for the Twitter account.
    public var accessToken: String

    /// The secret access token for the Twitter account.
    public var secretAccessToken: String

    /// The OAuth verifier for the Twitter account.
    public var oauthVerifier: String

    /// The ID of the associated OAuth token.
    public var oauthTokenID: UUID?

    /// Initializes a new instance of `TwitterUserTokenDTO`.
    /// - Parameters:
    ///   - id: Unique identifier for the Twitter user token.
    ///   - createdAt: The date and time when the token was created.
    ///   - updatedAt: The date and time when the token was last updated.
    ///   - deletedAt: The date and time when the token was deleted.
    ///   - accessToken: The access token for the Twitter account.
    ///   - secretAccessToken: The secret access token for the Twitter account.
    ///   - oauthVerifier: The OAuth verifier for the Twitter account.
    ///   - oauthTokenID: The ID of the associated OAuth token.
    public init(
        id: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil,
        accessToken: String,
        secretAccessToken: String,
        oauthVerifier: String,
        oauthTokenID: UUID? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.accessToken = accessToken
        self.secretAccessToken = secretAccessToken
        self.oauthVerifier = oauthVerifier
        self.oauthTokenID = oauthTokenID
    }
}
