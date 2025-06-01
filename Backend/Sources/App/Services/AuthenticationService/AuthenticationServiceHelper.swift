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

    public func validateAndDeleteCode(_ authCodePayload: AuthPhoneCodePayloadDTO) async throws {
        let validator = AuthenticationCodeValidator(
            .init(
                writeDb: config.writeDb, readDb: config.readDb, logger: config.logger
            ),
            authCodePayload: authCodePayload
        )
        try await validator.validateAndDeleteCode()
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

    public func deleteOldTokens(_ payload: DeleteOldAccessTokensPayload) async throws {
        try await OldAccessTokenDeleter(
            .init(writeDb: config.writeDb,
                  readDb: config.readDb,
                  logger: config.logger,
                  payload: payload)
        ).deleteOldTokens()
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
        // TODO: make env variable more descriptive (update local env files, obsidian, gh jobs, and all deployed envs)
        try Environment.getOrThrow("AUTHENTICATION_CODE_DISTANCE")
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

    public func sendAuthCode(_ payload: SendAuthCodePayload) async throws -> AuthenticationCodeResponseDTO {
        try await AuthCodeSender(.init(
            writeDb: config.writeDb,
            readDb: config.writeDb,
            logger: config.logger,
            payload: payload
        )).send()
    }

    // TODO: cleanup, don't throw error at top level
    // (have name be `logAuthCodeNotSent`)
    public func handleAuthCodeNotSent(
        code: String,
        phoneNumber: String,
        codeModelId: UUID,
        error: GenericErrors
    ) throws {
        BackendMetric.totalFailedVerificationCodesSent.increment()
        config.logger.error(
            "Couldn't sent verification code to user",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "phoneNumber": .string(phoneNumber),
                "code": .string(code),
                "codeId": .string(codeModelId.uuidString),
                "error": .string(error.rawValue),
            ]
        )
        throw error
    }

    // TODO: remove method, use above method instead of this one
    public func handleAuthCodeNotSent(
        code: String,
        phoneNumber: String,
        codeModelId: UUID,
        error: any Error
    ) throws {
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
        throw GenericErrors.unknownError
    }
}

internal struct AuthenticationCodeValidator {
    private let config: AuthenticationServiceHelperConfig
    private let authCodePayload: AuthPhoneCodePayloadDTO
    private let messageService = MessageService()

    init(_ config: AuthenticationServiceHelperConfig, authCodePayload: AuthPhoneCodePayloadDTO) {
        self.config = config
        self.authCodePayload = authCodePayload
    }

    public func validateAndDeleteCode() async throws {
        try sendTelemetryDataOnValidateAndDeleteCodeAttempt()

        let validCode = try await getAndValidateCode()
        try await validCode.delete(on: config.writeDb)
    }

    private func sendTelemetryDataOnValidateAndDeleteCodeAttempt() throws {
        try messageService.sendDiscordWebhookAppEvent(
            input: authCodePayload.phoneNumber,
            event: "submitted authentication code to validate `\(authCodePayload.code)`",
            logger: config.logger
        )
    }

    private func getAndValidateCode() async throws
        -> AuthenticationCodeModel
    {
        let authCode = try await getAuthCode()
        return try validateAndReturnAuthCode(authCode)
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
                "authCodePayload": .string(String(reflecting: authCodePayload))
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
                "authCodePayload": .string(String(reflecting: authCodePayload)),
                "validCode": .string(String(reflecting: validCode)),
            ]
        )
    }

    private func logInvalidCodeError() {
        config.logger.error(
            "Authentication code is invalid",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "authCodePayload": .string(String(reflecting: authCodePayload))
            ]
        )
    }

    private func getAuthCode() async throws -> AuthenticationCodeModel? {
        try await AuthenticationCodeModel
            .query(on: config.readDb)
            .filter(\.$phoneNumber == authCodePayload.phoneNumber)
            .filter(\.$code == authCodePayload.code.lowercased())
            .first()
    }
}

struct AuthenticationServiceHelperConfig: AuthenticationServiceConfig {
    let writeDb: Database
    let readDb: Database
    let logger: Logger
}

internal struct DeleteOldAccessTokensPayload {
    let userId: UUID
    let subject: JWTTokenSubject
}

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
                payload: .init(userId: config.payload.userId, subject: config.payload.subject)
            )
        ).deleteOldTokens(skip: 5)
        try await createAuthToken(fromSignedToken: signedToken)
        return signedToken
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

internal struct OldAccessTokenDeleter {
    let config: OldAccessTokenDeleterConfig

    init(_ config: OldAccessTokenDeleterConfig) {
        self.config = config
    }

    // TODO: refactor
    public func deleteOldTokens(
        skip: Int? = nil
    ) async throws {
        let subject = config.payload.subject
        let userId = config.payload.userId

        config.logger.info(
            "Deleting old tokens",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "userId": .string(userId.uuidString),
                "subject": .string(String(reflecting: subject)),
                "skip": .string(String(reflecting: skip)),
            ]
        )

        var query = JwtTokenModel.query(on: config.writeDb)
            .filter(\.$userId == userId)
            .filter(\.$subject == subject)
            .sort(\.$createdAt, .descending)

        if let skip {
            query = query.range(skip...)
        }

        let tokensToDelete = try await query.all()

        for token in tokensToDelete {
            try await token.delete(on: config.writeDb)
            config.logger.info(
                "Deleted token",
                metadata: [
                    "to": .string("AuthenticationService.deleteOldTokens"),
                    "tokenId": .string(token.id?.uuidString ?? "unknown"),
                ]
            )
        }
    }
}

internal struct OldAccessTokenDeleterConfig: AuthenticationServiceConfig {
    let writeDb: Database
    let readDb: Database
    let logger: Logger
    let payload: DeleteOldAccessTokensPayload
}

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

    private func sendTelemetryDataOnCreateSuccess(payload tokensPayload: AuthenticationTokensPayloadDTO) throws {
        logCreateSuccess(payload: tokensPayload)
        try alertCreateSuccess(payload: tokensPayload)
    }

    private func alertCreateSuccess(payload tokensPayload: AuthenticationTokensPayloadDTO) throws {
        try messageService.sendDiscordWebhookAppEvent(
            input: config.payload.userId.uuidString,
            event: "generated tokens: `access: \(tokensPayload.accessToken.count)` `refresh: \(tokensPayload.refreshToken.count)`",
            logger: config.logger
        )
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

    private func logCreateStart() {
        config.logger.info(
            "Creating authentication tokens payload",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "userId": .string(config.payload.userId.uuidString),
            ]
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

internal struct AuthCodeSenderConfig: AuthenticationServiceConfig {
    let writeDb: Database
    let readDb: Database
    let logger: Logger
    let payload: SendAuthCodePayload
}

// TODO: Put queues and other similar Vapor structs with logger (not in payload)
internal struct SendAuthCodePayload {
    let queue: Queue
    let code: String
    let phoneNumber: String
    let codeModelId: UUID
}

internal struct AuthCodeSender {
    private let config: AuthCodeSenderConfig

    init(_ config: AuthCodeSenderConfig) {
        self.config = config
    }

    public func send() async throws -> AuthenticationCodeResponseDTO {
        try await startSendCodeJob()
        try await createAuthCodeModel()
        sendTelemetryDataOnSendSuccess()
        return sendSuccess()
    }

    private func sendSuccess() -> AuthenticationCodeResponseDTO {
        .init(success: true, timeout: 60)
    }

    private func sendTelemetryDataOnSendSuccess() {
        config.logger.info(
            "Sent verification code to user",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "phoneNumber": .string(config.payload.phoneNumber),
                "code": .string(config.payload.code),
                "codeId": .string(config.payload.codeModelId.uuidString),
            ]
        )

        BackendMetric.totalSuccessfulVerificationCodesSent.increment()
    }

    private func createAuthCodeModel() async throws {
        try await AuthenticationCodeModel(
            id: config.payload.codeModelId,
            code: config.payload.code,
            phoneNumber: config.payload.phoneNumber,
            deletedAt: getCodeDeletionTime()
        ).save(on: config.writeDb)
    }

    private func startSendCodeJob() async throws {
        try await config.payload.queue.dispatch(
            TransactionalMessageAsyncJob.self,
            .init(
                content: MessageFormatterService
                    .craftVerificationCodeMessage(
                        code: config.payload.code
                    ),
                toPhoneNumber: config.payload.phoneNumber
            )
        )
    }

    private func getCodeDeletionTime() -> Date {
        Date().addingTimeInterval(15 * 60)
    }
}
