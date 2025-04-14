// JWTTokenPayload.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation
import JWT

/// Token subject, either an access or refresh token
public enum JWTTokenSubject: String, Codable, Sendable {
    case access
    case refresh
}

/// Data contained in JWT tokens used for user authentication
public struct JWTTokenPayload: JWTPayload {
    private enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case userId = "uid"
        case tokenId = "tid"
    }

    public var subject: JWTTokenSubject

    public var expiration: ExpirationClaim

    public var userId: String

    public let tokenId: UUID

    public func verify(using _: some JWTAlgorithm) throws {
        try expiration.verifyNotExpired()
    }

    public init(
        subject: JWTTokenSubject,
        expiration: ExpirationClaim,
        userId: String,
        tokenId: UUID
    ) {
        self.subject = subject
        self.expiration = expiration
        self.userId = userId
        self.tokenId = tokenId
    }
}
