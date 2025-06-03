// AuthenticationCodeValidator.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import JWT
import Queues
import Vapor

internal struct AuthenticationCodeValidator {
    private let config: AuthenticationCodeValidatorConfig
    private let messageService = MessageService()

    init(_ config: AuthenticationCodeValidatorConfig) {
        self.config = config
    }

    public func validateAndDeleteCode() async throws {
        try sendTelemetryDataOnValidateAndDeleteCodeAttempt()
        try await getAndValidateCode().delete(on: config.writeDb)
    }

    private func sendTelemetryDataOnValidateAndDeleteCodeAttempt() throws {
        try messageService.sendDiscordWebhookAppEvent(
            input: config.payload.phoneNumber,
            event: "submitted authentication code to validate `\(config.payload.code)`",
            logger: config.logger
        )
    }

    private func getAndValidateCode() async throws
        -> AuthenticationCodeModel
    {
        let authCode = try await getAuthCode()
        return try validateAndReturnAuthCode(authCode)
    }

    private func getAuthCode() async throws -> AuthenticationCodeModel? {
        try await AuthenticationCodeModel
            .query(on: config.readDb)
            .filter(\.$phoneNumber == config.payload.phoneNumber)
            .filter(\.$code == config.payload.code.lowercased())
            .first()
    }

    private func validateAndReturnAuthCode(
        _ authCode: AuthenticationCodeModel?
    ) throws -> AuthenticationCodeModel {
        logValidateCodeStart()
        guard
            let validCode = authCode
        else {
            logInvalidCodeError()
            throw GenericErrors.invalidCode
        }
        logValidCode(code: validCode)
        return validCode
    }

    private func logValidateCodeStart() {
        config.logger.info(
            "Starting validation of authentication code",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "authCodePayload": .string(String(reflecting: config.payload))
            ]
        )
    }

    private func logInvalidCodeError() {
        config.logger.error(
            "Authentication code is invalid",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "authCodePayload": .string(String(reflecting: config.payload))
            ]
        )
    }

    private func logValidCode(
        code validCode: AuthenticationCodeModel
    ) {
        config.logger.info(
            "Authentication code is valid",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "authCodePayload": .string(String(reflecting: config.payload)),
                "validCode": .string(String(reflecting: validCode)),
            ]
        )
    }
}

internal struct AuthenticationCodeValidatorConfig: AuthenticationServiceConfig {
    let writeDb: Database
    let readDb: Database
    let logger: Logger
    let payload: AuthPhoneCodePayloadDTO
}
