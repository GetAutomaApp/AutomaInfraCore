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
    public let writeDb: Database
    public let readDb: Database
    public let logger: Logger
    public let helper: AuthenticationServiceHelper

    init(
        writeDb: Database,
        readDb: Database,
        logger: Logger
    ) {
        self.writeDb = writeDb
        self.readDb = readDb
        self.logger = logger

        helper = .init(writeDb: writeDb, readDb: readDb, logger: logger)
    }

    // 1. Register
    // This method will create a new User with a specific phone number
    public func register(
        payload: AuthPhoneCodePayloadDTO,
        signer: Request.JWT,
        queue: Queue
    ) async throws -> AuthenticationTokensPayloadDTO {
        let messageService = MessageService()
        let profilePictureService = ProfilePictureService(logger: logger)

        try await helper.getValidateAndDeleteCode(
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

        return try await helper.createAuthenticationTokensPayload(
            userId: userId.uuidString,
            signer: signer
        )
    }

    // 2. Send Login Auth Code
    // This will also be used to send the user a registeration code
    // We don't care if the user exists in this route or not
    public func sendAuthCode(phoneNumber: String, queue: Queue) async throws -> AuthenticationCodeResponseDTO {
        let code = RandomService.randomCode()

        logger.info(
            "Sending verification code to user",
            metadata: [
                "to": .string("AuthenticationService.sendAuthCode"),
                "phoneNumber": .string(phoneNumber),
                "code": .string(code),
            ]
        )

        let distance = try helper.getDistance()
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
            return try await helper.sendAuthCode(
                queue: queue,
                code: code,
                phoneNumber: phoneNumber,
                codeModelId: codeModelId
            )
        } catch let error as GenericErrors {
            try helper.handleAuthCodeNotSent(
                code: code,
                phoneNumber: phoneNumber,
                codeModelId: codeModelId,
                error: error
            )
        } catch {
            try helper.handleAuthCodeNotSent(
                code: code,
                phoneNumber: phoneNumber,
                codeModelId: codeModelId,
                error: error
            )
        }
        throw Abort(.internalServerError)
    }

    // 3. Login
    public func login(
        payload: AuthPhoneCodePayloadDTO,
        signer: Request.JWT
    ) async throws -> AuthenticationTokensPayloadDTO {
        let messageService = MessageService()
        try await helper.getValidateAndDeleteCode(
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

            return try await helper.createAuthenticationTokensPayload(
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
    public func refreshToken(userId: String, signer: Request.JWT) async throws -> String {
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

            return try await helper.generateAccessToken(
                userId: userId,
                expiresIn: 86_400,
                type: .access,
                signer: signer
            )
        } catch {
            BackendMetric.totalFailedTokensRefreshed.increment()
            throw error
        }
    }

    // 5. Logout
    public func logout(userId: UUID) async throws {
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

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await helper.deleteOldTokens(userId: userId, subject: .refresh)
            }
            group.addTask {
                try await helper.deleteOldTokens(userId: userId, subject: .access)
            }

            try await group.waitForAll()
        }
    }

    public func doesUserExist(phoneNumber: String) async throws -> Bool {
        do {
            let exists = try await UserModel.query(on: readDb).filter(\.$phoneNumber == phoneNumber).first() != nil

            if exists {
                BackendMetric.totalUsersAlreadyExists.increment()
                return true
            }
            return false
        } catch {
            logger.error(
                "Error checking if user exists.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "phoneNumber": .string(phoneNumber),
                    "error": .string("\(error.localizedDescription)"),
                ]
            )
            throw Abort(.internalServerError)
        }
    }
}
