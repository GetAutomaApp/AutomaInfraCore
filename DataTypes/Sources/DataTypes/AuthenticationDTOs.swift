// AuthenticationDTOs.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation
import JWT

public enum JWTTokenSubject: String, Codable, Sendable {
    case access
    case refresh
}

public struct JWTTokenPayload: JWTPayload {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case userId = "uid"
        case tokenId = "tid"
    }

    public var subject: JWTTokenSubject

    public var expiration: ExpirationClaim

    public var userId: String

    public let tokenId: UUID

    public func verify(using _: some JWTAlgorithm) async throws {
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

public enum AuthenticationError: Error {
    case invalidCode
    case userAlreadyExists
    case userNotFound
    case invalidToken
    case invalidUserId
}
