// AccessTokenResetter.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import JWT
import Queues
import Vapor

internal struct AccessTokenResetter {
    private let config: AccessTokenResetterConfig
    private let expiresAt: Date

    init(_ config: AccessTokenResetterConfig) {
        self.config = config
        expiresAt = Date().addingTimeInterval(config.payload.expiresIn)
    }

    public func reset() async throws -> String {
        let signedToken = try await getSignedToken()
        try await OldAccessTokenDeleter(
            .init(
                writeDb: config.writeDb,
                readDb: config.readDb,
                logger: config.logger,
                payload: .init(
                    userId: config.payload.userId,
                    subject: config.payload.subject,
                    totalNewestTokensToSkip: 5
                )
            )
        ).deleteOldTokens()
        try await createAuthToken(fromSignedToken: signedToken)
        return signedToken
    }

    private func getSignedToken() async throws -> String {
        try await config.payload.signer.sign(createTokenToSign())
    }

    private func createTokenToSign() -> JWTTokenPayload {
        JWTTokenPayload(
            subject: config.payload.subject,
            expiration: .init(value: expiresAt),
            userId: config.payload.userId.uuidString,
            tokenId: UUID()
        )
    }

    private func createAuthToken(fromSignedToken signedToken: String) async throws {
        try await JwtTokenModel(
            id: UUID(),
            token: signedToken,
            userId: config.payload.userId,
            subject: config.payload.subject,
            deletedAt: expiresAt
        ).create(on: config.writeDb)
    }
}

internal struct AccessTokenResetterConfig: AuthenticationServiceConfig {
    let writeDb: Database
    let readDb: Database
    let logger: Logger
    let payload: ResetAccessCodePayload
}

internal struct ResetAccessCodePayload {
    let userId: UUID
    let expiresIn: TimeInterval
    let subject: JWTTokenSubject
    let signer: Request.JWT
}
