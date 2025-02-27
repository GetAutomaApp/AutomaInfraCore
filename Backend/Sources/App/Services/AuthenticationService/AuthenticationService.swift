// AuthenticationService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import JWT
import Queues
import Vapor

struct AuthenticationService: Sendable {
    let writeDb: Database
    let readDb: Database
    let logger: Logger

    func getValidateAndDeleteCode(phoneNumber: String, code: String) async throws {
        logger.info(
            "Starting validation of authentication code",
            metadata: [
                "phoneNumber": .string(phoneNumber),
                "code": .string(code),
                "to": .string("AuthenticationService.getValidateAndDeleteCode"),
            ]
        )

        let messageService = MessageService()
        let validCode = try await AuthenticationCodeModel
            .query(on: readDb)
            .filter(\.$phoneNumber == phoneNumber)
            .filter(\.$code == code.lowercased())
            .first()

        guard let validCode else {
            logger.error(
                "Authentication code is invalid",
                metadata: [
                    "to": .string("AuthenticationService.getValidateAndDeleteCode"),
                    "code": .string(code),
                    "phoneNumber": .string(phoneNumber),
                    "validCode": .string(String(describing: validCode)),
                ]
            )
            throw GenericErrors.invalidCode
        }

        logger.info(
            "Authentication code is valid",
            metadata: [
                "to": .string("AuthenticationService.getValidateAndDeleteCode"),
                "code": .string(code),
                "phoneNumber": .string(phoneNumber),
                "validCode": .string(String(describing: validCode)),
            ]
        )

        try messageService.sendDiscordWebhookAppEvent(
            input: phoneNumber,
            event: "submitted valid code `\(code)`",
            logger: logger
        )

        try await validCode.delete(on: writeDb)
    }

    // 1. Register
    // This method will create a new User with a specific phone number
    func register(payload: AuthPhoneCodePayloadDTO,
                  signer: Request.JWT, queue: Queue) async throws -> AuthenticationTokensPayloadDTO
    { let messageService = MessageService()
        let profilePictureService = ProfilePictureService(logger: logger)

        try await getValidateAndDeleteCode(
            phoneNumber: payload.phoneNumber,
            code: payload.code
        )

        let username = RandomService.randomUsername()

        let userId = UUID()

        let user = UserModel(
            id: userId,
            username: username,
            phoneNumber: payload.phoneNumber,
            accepted: false
        )

        let userDTO = user.toDTO()
        let profilePictureKey = try profilePictureService.generateImageKey(for: userDTO)

        try await queue.dispatch(ProfilePictureAsyncJob.self, .init(payload: userDTO))

        user.profilePictureKey = profilePictureKey

        try await user.save(on: writeDb)

        BackendMetric.totalUsersCreated.increment()

        logger.info(
            "Successfully Registered User",
            metadata: [
                "to": .string("AuthenticationService.register"),
                "userId": .string(userId.uuidString),
                "username": .string(username),
            ]
        )

        try messageService
            .sendDiscordWebhookAppEvent(
                input: "\(payload.phoneNumber) - \(userId)",
                event: "created an account with \(username)",
                logger: logger
            )

        return try await createAuthenticationTokensPayload(
            userId: userId.uuidString,
            signer: signer
        )
    }

    // 2. Send Login Auth Code
    // This will also be used to send the user a registeration code
    // We don't care if the user exists in this route or not
    func sendAuthCode(phoneNumber: String, queue: Queue) async throws -> AuthenticationCodeResponseDTO {
        let code = RandomService.randomCode()

        logger.info(
            "Sending verification code to user",
            metadata: [
                "to": .string("AuthenticationService.sendAuthCode"),
                "phoneNumber": .string(phoneNumber),
                "code": .string(code),
            ]
        )

        let distance: Double = 60 // TODO: Convert this to a constant ENV var
        let dateToCheck = Date()
        if
            let mostRecentCodeSent = try await AuthenticationCodeModel
            .query(on: readDb)
            .filter(\.$createdAt > dateToCheck.addingTimeInterval(-distance))
            .filter(\.$phoneNumber == phoneNumber)
            .first()
        {
            let timeout = distance - (mostRecentCodeSent.createdAt?.distance(to: dateToCheck) ?? distance)
            return .init(success: timeout == 0, timeout: timeout)
        }

        let codeModelId = UUID()

        do {
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
        } catch let error as GenericErrors {
            BackendMetric.totalFailedVerificationCodesSent.increment()
            logger.error(
                "Couldn't Sent verification code to user",
                metadata: [
                    "to": .string("AuthenticationService.sendAuthCode"),
                    "phoneNumber": .string(phoneNumber),
                    "code": .string(code),
                    "codeId": .string(codeModelId.uuidString),
                    "error": .string(error.rawValue),
                ]
            )
            throw error
        } catch {
            BackendMetric.totalFailedVerificationCodesSent.increment()
            logger.error(
                "Couldn't Sent verification code to user",
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

    // 3. Login
    func login(payload: AuthPhoneCodePayloadDTO, signer: Request.JWT) async throws -> AuthenticationTokensPayloadDTO {
        let messageService = MessageService()
        try await getValidateAndDeleteCode(
            phoneNumber: payload.phoneNumber,
            code: payload.code
        )

        let user = try await UserModel.query(on: readDb).filter(
            \.$phoneNumber == payload.phoneNumber
        ).first()

        if let user, let userId = user.id?.uuidString {
            try messageService
                .sendDiscordWebhookAppEvent(input: "\(payload.phoneNumber) - \(user.username)",
                                            event: "logging in with code: `\(payload.code)`", logger: logger)

            logger.info(
                "Logging in user",
                metadata: [
                    "to": .string("AuthenticationService.login"),
                    "userId": .string(userId),
                    "username": .string(user.username),
                ]
            )

            return try await createAuthenticationTokensPayload(
                userId: userId,
                signer: signer
            )
        } else {
            logger.error(
                "Can't login non-existent user",
                metadata: [
                    "to": .string("AuthenticationService.login"),
                    "phoneNumber": .string(payload.phoneNumber),
                ]
            )
            throw GenericErrors.userNotFound
        }
    }

    // 4. Refresh Token
    func refreshToken(userId: String, signer: Request.JWT) async throws -> String {
        do {
            let messageService = MessageService()

            try messageService
                .sendDiscordWebhookAppEvent(
                    input: userId,
                    event: "is refreshing their access token",
                    logger: logger
                )

            logger.info(
                "Refreshing user access token",
                metadata: [
                    "to": .string("AuthenticationService.refreshToken"),
                    "userId": .string(userId),
                ]
            )

            return try await generateAccessToken(
                userId: userId,
                expiresIn: 86400,
                type: .access,
                signer: signer
            )
        } catch {
            BackendMetric.totalFailedTokensRefreshed.increment()
            throw error
        }
    }

    // 5. Logout
    func logout(userId: UUID) async throws {
        let messageService = MessageService()

        try messageService
            .sendDiscordWebhookAppEvent(
                input: userId.uuidString,
                event: "is logging out",
                logger: logger
            )

        logger.info(
            "Logging user out",
            metadata: [
                "to": .string("AuthenticationService.refreshToken"),
                "userId": .string(userId.uuidString),
            ]
        )

        try await deleteOldTokens(userId: userId, subject: .refresh)
        try await deleteOldTokens(userId: userId, subject: .access)
    }

    func codeDeletionTime() -> Date {
        Date().addingTimeInterval(15 * 60)
    }

    func doesUserExist(phoneNumber: String) async throws -> Bool {
        let exists = try await UserModel.query(on: readDb).filter(\.$phoneNumber == phoneNumber).first() != nil

        if exists {
            BackendMetric.totalUsersAlreadyExists.increment()
            return true
        }

        return false
    }

    func generateAccessToken(
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

    func deleteOldTokens(
        userId: UUID,
        subject: JWTTokenSubject,
        skip: Int? = nil
    ) async throws {
        logger.info(
            "Deleting old tokens",
            metadata: [
                "to": .string("AuthenticationService.deleteOldTokens"),
                "userId": .string(userId.uuidString),
                "subject": .string(String(describing: subject)),
                "skip": .string(String(describing: skip)),
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

    func createAuthenticationTokensPayload(userId: String,
                                           signer: Request.JWT) async throws -> AuthenticationTokensPayloadDTO
    {
        logger.info(
            "Creating authentication tokens payload",
            metadata: [
                "to": .string("AuthenticationService.createAuthenticationTokensPayload"),
                "userId": .string(userId),
            ]
        )

        let messageService = MessageService()
        let accessToken = try await generateAccessToken(userId: userId, expiresIn: 86400, type: .access, signer: signer)
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

        try messageService.sendDiscordWebhookAppEvent(input: userId,
                                                      event: "generated tokens: `access: \(accessToken.count)` `refresh: \(refreshToken.count)`",
                                                      logger: logger)

        return tokensPayload
    }
}
