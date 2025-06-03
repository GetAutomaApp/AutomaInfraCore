// AuthenticationServiceHelper.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import JWT
import Queues
import Vapor

actor AuthenticationServiceHelper {
    private let config: AuthenticationServiceHelperConfig
    private let messageService = MessageService()

    init(_ config: AuthenticationServiceHelperConfig) {
        self.config = config
    }

    public func sendAuthCode(_ payload: SendAuthCodePayload, queue: Queue) async throws -> AuthenticationCodeResponseDTO
    {
        try await AuthCodeSender(.init(
            writeDb: config.writeDb,
            readDb: config.writeDb,
            logger: config.logger,
            queue: queue,
            payload: payload
        )).send()
    }

    public func validateAndDeleteCode(_ payload: AuthPhoneCodePayloadDTO) async throws {
        try await AuthenticationCodeValidator(
            .init(
                writeDb: config.writeDb, readDb: config.readDb, logger: config.logger, payload: payload
            )
        ).validateAndDeleteCode()
    }

    public func deleteOldTokens(_ payload: DeleteOldAccessTokensPayload) async throws {
        try await OldAccessTokenDeleter(
            .init(writeDb: config.writeDb,
                  readDb: config.readDb,
                  logger: config.logger,
                  payload: payload)
        ).deleteOldTokens()
    }

    public func resetAccessToken(_ payload: ResetAccessCodePayload) async throws -> String {
        try await AccessTokenResetter(.init(
            writeDb: config.writeDb,
            readDb: config.readDb,
            logger: config.logger,
            payload: payload
        ))
        .reset()
    }

    public func createAuthenticationTokensPayload(_ payload: CreateAuthenticationTokensPayload) async throws
        -> AuthenticationTokensPayloadDTO
    {
        try await AuthenticationTokensPayloadCreator(.init(
            writeDb: config.writeDb,
            readDb: config.readDb,
            logger: config.logger,
            payload: payload
        )).create()
    }

    public func getCodeRateLimit() throws -> Double {
        try castCodeRateLimitToNumber(getRateLimitString())
    }

    private func getRateLimitString() throws -> String {
        try Environment.getOrThrow("AUTHENTICATION_CODE_RATE_LIMIT")
    }

    private func castCodeRateLimitToNumber(_ rateLimitString: String) throws -> Double {
        guard
            let rateLimitNumber = Double(rateLimitString)
        else {
            logCodeRateLimitNotCasted(rateLimit: rateLimitString)
            throw Abort(.internalServerError)
        }
        return rateLimitNumber
    }

    private func logCodeRateLimitNotCasted(rateLimit: String) {
        config.logger.error(
            "Could not convert AUTHENTICATION_CODE_DISTANCE raw value to Double.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "distance_raw_value": .string(rateLimit),
            ]
        )
    }

    public func sendTelemetryDataOnAuthCodeSendFail(
        code: String,
        phoneNumber: String,
        codeModelId: UUID,
        error: any Error
    ) {
        BackendMetric.totalFailedVerificationCodesSent.increment()
        config.logger.error(
            "Couldn't sent verification code to user",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "phoneNumber": .string(phoneNumber),
                "code": .string(code),
                "codeId": .string(codeModelId.uuidString),
                "error": .string(error.localizedDescription),
            ]
        )
    }
}

struct AuthenticationServiceHelperConfig: AuthenticationServiceConfig {
    let writeDb: Database
    let readDb: Database
    let logger: Logger
}
