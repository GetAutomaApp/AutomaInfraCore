// AuthenticationTokensPayloadCreator.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import JWT
import Queues
import Vapor

internal struct AuthenticationTokensPayloadCreator {
    private let config: AuthenticationTokensPayloadCreatorConfig
    private let messageService = MessageService()

    init(_ config: AuthenticationTokensPayloadCreatorConfig) {
        self.config = config
    }

    public func create(
    ) async throws -> AuthenticationTokensPayloadDTO {
        logCreateStart()

        let tokensPayload = try await createTokensPayload()
        try sendTelemetryDataOnCreateSuccess(payload: tokensPayload)

        return tokensPayload
    }

    private func logCreateStart() {
        config.logger.info(
            "Creating authentication tokens payload",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "userId": .string(config.payload.userId.uuidString),
            ]
        )
    }

    private func createTokensPayload() async throws -> AuthenticationTokensPayloadDTO {
        try await .init(
            accessToken: resetAccessToken(subject: .access),
            refreshToken: resetAccessToken(subject: .refresh)
        )
    }

    private func resetAccessToken(subject: JWTTokenSubject) async throws -> String {
        try await AccessTokenResetter(.init(
            writeDb: config.writeDb,
            readDb: config.readDb,
            logger: config.logger,
            payload: .init(
                userId: config.payload.userId,
                expiresIn: getExpiresInFromSubject(subject),
                subject: subject,
                signer: config.payload.signer
            )
        )).reset()
    }

    private func getExpiresInFromSubject(_ subject: JWTTokenSubject) -> TimeInterval {
        switch subject {
        case .refresh:
            31_536_000
        default:
            86_400
        }
    }

    private func sendTelemetryDataOnCreateSuccess(payload tokensPayload: AuthenticationTokensPayloadDTO) throws {
        logCreateSuccess(payload: tokensPayload)
        try alertCreateSuccess(payload: tokensPayload)
    }

    private func logCreateSuccess(payload tokensPayload: AuthenticationTokensPayloadDTO) {
        config.logger.info(
            "Successfully created authentication tokens payload",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "userId": .string(config.payload.userId.uuidString),
                "accessTokenLength": .string("\(tokensPayload.accessToken.count)"),
                "refreshTokenLength": .string("\(tokensPayload.refreshToken.count)"),
            ]
        )
    }

    private func alertCreateSuccess(payload tokensPayload: AuthenticationTokensPayloadDTO) throws {
        try messageService.sendDiscordWebhookAppEvent(
            input: config.payload.userId.uuidString,
            event: "generated tokens: `access: \(tokensPayload.accessToken.count)` `refresh: \(tokensPayload.refreshToken.count)`",
            logger: config.logger
        )
    }
}

internal struct AuthenticationTokensPayloadCreatorConfig: AuthenticationServiceConfig {
    let writeDb: Database
    let readDb: Database
    let logger: Logger
    let payload: CreateAuthenticationTokensPayload
}

internal struct CreateAuthenticationTokensPayload {
    let userId: UUID
    let signer: Request.JWT
}
