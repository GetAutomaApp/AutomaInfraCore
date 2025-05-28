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
    public let writeDb: Database
    public let readDb: Database
    public let logger: Logger
    private let messageService: MessageService

    init(writeDb: Database, readDb: Database, logger: Logger, messageService: MessageService) {
        self.writeDb = writeDb
        self.readDb = readDb
        self.logger = logger
        self.messageService = messageService
    }

    public func validateAndDeleteCode(_ authCodePayload: AuthPhoneCodePayloadDTO) async throws {
        try messageService.sendDiscordWebhookAppEvent(
            input: authCodePayload.phoneNumber,
            event: "submitted valid code `\(authCodePayload.code)`",
            logger: logger
        )

        let validCode = try await getAndValidateCode(authCodePayload)
        try await validCode.delete(on: writeDb)
    }

    private func getAndValidateCode(_ authCodePayload: AuthPhoneCodePayloadDTO) async throws
        -> AuthenticationCodeModel
    {
        logger.info(
            "Starting validation of authentication code",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "authCodePayload": .string(String(reflecting: authCodePayload))
            ]
        )

        let authCode = try await getAuthCode(authCodePayload)
        return try validateAndReturnAuthCode(authCode, payload: authCodePayload)
    }

    private func validateAndReturnAuthCode(
        _ authCode: AuthenticationCodeModel?,
        payload authCodePayload: AuthPhoneCodePayloadDTO
    ) throws -> AuthenticationCodeModel {
        guard
            let validCode = authCode
        else {
            logger.error(
                "Authentication code is invalid",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "authCodePayload": .string(String(reflecting: authCodePayload))
                ]
            )
            throw GenericErrors.invalidCode
        }

        logger.info(
            "Authentication code is valid",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "authCodePayload": .string(String(reflecting: authCodePayload)),
                "validCode": .string(String(reflecting: validCode)),
            ]
        )

        return validCode
    }

    private func getAuthCode(_ authCodePayload: AuthPhoneCodePayloadDTO) async throws -> AuthenticationCodeModel? {
        try await AuthenticationCodeModel
            .query(on: readDb)
            .filter(\.$phoneNumber == authCodePayload.phoneNumber)
            .filter(\.$code == authCodePayload.code.lowercased())
            .first()
    }

    public func codeDeletionTime() -> Date {
        Date().addingTimeInterval(15 * 60)
    }

    public func generateAccessToken(
        userId: String,
        expiresIn: TimeInterval,
        type subject: JWTTokenSubject,
        signer: Request.JWT
    ) async throws -> String {
        guard let userId = UUID(uuidString: userId) else {
            throw GenericErrors.invalidUserId
        }

        let expiresAt = Date().addingTimeInterval(expiresIn)
        let token = JWTTokenPayload(
            subject: subject,
            expiration: .init(value: expiresAt),
            userId: userId.uuidString,
            tokenId: UUID()
        )

        let signedToken = try await signer.sign(token)

        try await deleteOldTokens(userId: userId, subject: subject, skip: 5)

        let tokenId = UUID()

        try await JwtTokenModel(
            id: tokenId,
            token: signedToken,
            userId: userId,
            subject: subject,
            deletedAt: expiresAt
        ).create(on: writeDb)

        return signedToken
    }

    public func deleteOldTokens(
        userId: UUID,
        subject: JWTTokenSubject,
        skip: Int? = nil
    ) async throws {
        logger.info(
            "Deleting old tokens",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "userId": .string(userId.uuidString),
                "subject": .string(String(reflecting: subject)),
                "skip": .string(String(reflecting: skip)),
            ]
        )

        var query = JwtTokenModel.query(on: writeDb)
            .filter(\.$userId == userId)
            .filter(\.$subject == subject)
            .sort(\.$createdAt, .descending)

        if let skip {
            query = query.range(skip...)
        }

        let tokensToDelete = try await query.all()

        for token in tokensToDelete {
            try await token.delete(on: writeDb)
            logger.info(
                "Deleted token",
                metadata: [
                    "to": .string("AuthenticationService.deleteOldTokens"),
                    "tokenId": .string(token.id?.uuidString ?? "unknown"),
                ]
            )
        }
    }

    public func createAuthenticationTokensPayload(
        userId: String,
        signer: Request.JWT
    ) async throws -> AuthenticationTokensPayloadDTO {
        logger.info(
            "Creating authentication tokens payload",
            metadata: [
                "to": .string("AuthenticationService.createAuthenticationTokensPayload"),
                "userId": .string(userId),
            ]
        )

        let messageService = MessageService()

        let accessToken = try await generateAccessToken(
            userId: userId,
            expiresIn: 86_400,
            type: .access,
            signer: signer
        )
        let refreshToken = try await generateAccessToken(
            userId: userId,
            expiresIn: 31_536_000,
            type: .refresh,
            signer: signer
        )

        let tokensPayload: AuthenticationTokensPayloadDTO = .init(
            accessToken: accessToken,
            refreshToken: refreshToken
        )

        logger.info(
            "Successfully created authentication tokens payload",
            metadata: [
                "to": .string("AuthenticationService.createAuthenticationTokensPayload"),
                "userId": .string(userId),
                "accessTokenLength": .string("\(accessToken.count)"),
                "refreshTokenLength": .string("\(refreshToken.count)"),
            ]
        )

        try messageService.sendDiscordWebhookAppEvent(
            input: userId,
            event: "generated tokens: `access: \(accessToken.count)` `refresh: \(refreshToken.count)`",
            logger: logger
        )

        return tokensPayload
    }

    public func getDistance() throws -> Double {
        let distanceRawValue = try Environment.getOrThrow("AUTHENTICATION_CODE_DISTANCE")

        guard
            let distance = Double(distanceRawValue)
        else {
            logger.error(
                "Could not convert AUTHENTICATION_CODE_DISTANCE raw value to Double.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "distance_raw_value": .string(distanceRawValue),
                ]
            )
            throw Abort(.internalServerError)
        }
        return distance
    }

    public func sendAuthCode(
        queue: Queue,
        code: String,
        phoneNumber: String,
        codeModelId: UUID
    ) async throws -> AuthenticationCodeResponseDTO {
        try await queue.dispatch(
            TransactionalMessageAsyncJob.self,
            .init(
                content: MessageFormatterService
                    .craftVerificationCodeMessage(
                        code: code
                    ),
                toPhoneNumber: phoneNumber
            )
        )

        let codeModel = try AuthenticationCodeModel(
            id: codeModelId,
            code: code,
            phoneNumber: phoneNumber,
            deletedAt: codeDeletionTime()
        )

        try await codeModel.save(on: writeDb)

        logger.info(
            "Sent verification code to user",
            metadata: [
                "to": .string("AuthenticationService.sendAuthCode"),
                "phoneNumber": .string(phoneNumber),
                "code": .string(code),
                "codeId": .string(codeModelId.uuidString),
            ]
        )

        BackendMetric.totalSuccessfulVerificationCodesSent.increment()

        return .init(success: true, timeout: 60)
    }

    public func handleAuthCodeNotSent(
        code: String,
        phoneNumber: String,
        codeModelId: UUID,
        error: GenericErrors
    ) throws {
        BackendMetric.totalFailedVerificationCodesSent.increment()
        logger.error(
            "Couldn't sent verification code to user",
            metadata: [
                "to": .string("AuthenticationService.sendAuthCode"),
                "phoneNumber": .string(phoneNumber),
                "code": .string(code),
                "codeId": .string(codeModelId.uuidString),
                "error": .string(error.rawValue),
            ]
        )
        throw error
    }

    public func handleAuthCodeNotSent(
        code: String,
        phoneNumber: String,
        codeModelId: UUID,
        error: any Error
    ) throws {
        BackendMetric.totalFailedVerificationCodesSent.increment()
        logger.error(
            "Couldn't sent verification code to user",
            metadata: [
                "to": .string("AuthenticationService.sendAuthCode"),
                "phoneNumber": .string(phoneNumber),
                "code": .string(code),
                "codeId": .string(codeModelId.uuidString),
                "error": .string(error.localizedDescription),
            ]
        )
        throw GenericErrors.unknownError
    }
}
