// UserLoginService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import JWT
import Vapor

internal struct UserLoginService: AuthenticationService {
    var helper: AuthenticationServiceHelper
    let config: UserLoginConfig
    var messageService = MessageService()

    init(_ config: UserLoginConfig) {
        self.config = config
        helper = .init(.init(writeDb: config.writeDb, readDb: config.readDb, logger: config.logger))
    }

    func login() async throws -> AuthenticationTokensPayloadDTO {
        try await validateAuthCode()

        guard let user = try await findUser() else {
            logMissingUserError()
            throw GenericErrors.userNotFound
        }

        return try await completeLogin(for: user)
    }

    private func validateAuthCode() async throws {
        try await helper.validateAndDeleteCode(config.payload.authCodePayload)
    }

    private func findUser() async throws -> UserModel? {
        try await UserModel
            .query(on: config.readDb)
            .filter(\.$phoneNumber == config.payload.authCodePayload.phoneNumber)
            .first()
    }

    private func completeLogin(for user: UserModel) async throws -> AuthenticationTokensPayloadDTO {
        let userId: UUID
        do {
            userId = try user.requireID()
        } catch {
            config.logger.error("User model has no ID")
            throw GenericErrors.userNotFound
        }

        try await sendLoginWebhook(for: user)
        logUserLogin(userId: userId.uuidString, username: user.username)

        return try await helper.createAuthenticationTokensPayload(.init(userId: userId, signer: config.payload.signer))
    }

    private func sendLoginWebhook(for user: UserModel) async throws {
        try messageService.sendDiscordWebhookAppEvent(
            input: "\(config.payload.authCodePayload.phoneNumber) - \(user.username)",
            event: "logging in with code: `\(config.payload.authCodePayload.code)`",
            logger: config.logger
        )
    }

    private func logUserLogin(userId: String, username: String) {
        config.logger.info(
            "Logging in user",
            metadata: [
                "to": .string("AuthenticationService.login"),
                "userId": .string(userId),
                "username": .string(username),
            ]
        )
    }

    private func logMissingUserError() {
        config.logger.error(
            "Can't login non-existent user",
            metadata: [
                "to": .string("AuthenticationService.login"),
                "config": .string(String(describing: config.payload)),
            ]
        )
    }
}

struct UserLoginPayload {
    let authCodePayload: AuthPhoneCodePayloadDTO
    let signer: Request.JWT
}

struct UserLoginConfig: AuthenticationServiceConfig {
    let writeDb: Database
    let readDb: Database
    let logger: Logger
    let payload: UserLoginPayload
}
