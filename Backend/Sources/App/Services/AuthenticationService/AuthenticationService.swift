// AuthenticationService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import JWT
import Queues
import Vapor

public struct RootAuthenticationService: AuthenticationService {
    var config: any AuthenticationServiceConfig
    let helper: AuthenticationServiceHelper
    let messageService = MessageService()

    init(_ config: RootAuthenticationServiceConfig) {
        self.config = config
        helper = .init(.init(writeDb: config.writeDb, readDb: config.readDb, logger: config.logger))
    }

    func register(_ payload: UserRegistrationPayload) async throws -> AuthenticationTokensPayloadDTO {
        var registrator = UserRegistrationService(.init(
            writeDb: config.writeDb,
            readDb: config.readDb,
            logger: config.logger,
            payload: payload
        ))
        return try await registrator.register()
    }

    func login(_ payload: UserLoginPayload) async throws -> AuthenticationTokensPayloadDTO {
        let loginService = UserLoginService(.init(
            writeDb: config.writeDb,
            readDb: config.readDb,
            logger: config.logger,
            payload: payload
        ))
        return try await loginService.login()
    }

    public func sendAuthCode(phoneNumber: String, queue: Queue) async throws -> AuthenticationCodeResponseDTO {
        let code = RandomService.randomCode()
        logAuthCodeAttempt(phoneNumber: phoneNumber, code: code)

        if let timeout = try await existingCodeTimeout(phoneNumber: phoneNumber) {
            return .init(success: timeout == 0, timeout: timeout)
        }

        let codeModelId = UUID()

        return try await sendOrHandleAuthCode(
            phoneNumber: phoneNumber,
            queue: queue,
            code: code,
            codeModelId: codeModelId
        )
    }

    public func refreshToken(userId: UUID, signer: Request.JWT) async throws -> String {
        do {
            try await sendRefreshEvent(userId: userId.uuidString)
            logRefresh(userId: userId.uuidString)

            return try await helper.resetAccessToken(
                .init(
                    userId: userId, expiresIn: 86_400, subject: .access, signer: signer
                )
            )
        } catch {
            BackendMetric.totalFailedTokensRefreshed.increment()
            throw error
        }
    }

    public func logout(userId: UUID) async throws {
        try await sendLogoutEvent(userId: userId)
        logLogout(userId: userId)

        let concurrencySafeHelper: AuthenticationServiceHelper = .init(.init(
            writeDb: config.writeDb,
            readDb: config.readDb,
            logger: config.logger
        ))

        async let deleteRefresh: () = concurrencySafeHelper.deleteOldTokens(.init(userId: userId, subject: .refresh))
        async let deleteAccess: () = concurrencySafeHelper.deleteOldTokens(.init(userId: userId, subject: .access))

        _ = try await (deleteRefresh, deleteAccess)
    }

    public func doesUserExist(phoneNumber: String) async throws -> Bool {
        do {
            let exists = try await checkUserExists(phoneNumber: phoneNumber)
            if exists {
                BackendMetric.totalUsersAlreadyExists.increment()
            }
            return exists
        } catch {
            logUserExistenceError(phoneNumber: phoneNumber, error: error)
            throw Abort(.internalServerError)
        }
    }

    // MARK: - Private Helpers

    private func logAuthCodeAttempt(phoneNumber: String, code: String) {
        config.logger.info(
            "Sending verification code to user",
            metadata: [
                "to": .string("AuthenticationService.sendAuthCode"),
                "phoneNumber": .string(phoneNumber),
                "code": .string(code),
            ]
        )
    }

    private func existingCodeTimeout(phoneNumber: String) async throws -> TimeInterval? {
        let distance = try await helper.getDistance()
        let dateToCheck = Date()

        guard let recentCode = try await AuthenticationCodeModel
            .query(on: config.readDb)
            .filter(\.$createdAt > dateToCheck.addingTimeInterval(-distance))
            .filter(\.$phoneNumber == phoneNumber)
            .first()
        else {
            return nil
        }

        return distance - (recentCode.createdAt?.distance(to: dateToCheck) ?? distance)
    }

    // TODO: This method does more than one thing. Refactor.
    private func sendOrHandleAuthCode(
        phoneNumber: String,
        queue: Queue,
        code: String,
        codeModelId: UUID
    ) async throws -> AuthenticationCodeResponseDTO {
        do {
            return try await helper.sendAuthCode(
                queue: queue,
                code: code,
                phoneNumber: phoneNumber,
                codeModelId: codeModelId
            )
        } catch let error as GenericErrors {
            try await helper.handleAuthCodeNotSent(
                code: code,
                phoneNumber: phoneNumber,
                codeModelId: codeModelId,
                error: error
            )
        } catch {
            try await helper.handleAuthCodeNotSent(
                code: code,
                phoneNumber: phoneNumber,
                codeModelId: codeModelId,
                error: error
            )
        }
        throw Abort(.internalServerError)
    }

    private func sendRefreshEvent(userId: String) async throws {
        try messageService.sendDiscordWebhookAppEvent(
            input: userId,
            event: "is refreshing their access token",
            logger: config.logger
        )
    }

    private func logRefresh(userId: String) {
        config.logger.info(
            "Refreshing user access token",
            metadata: [
                "to": .string("AuthenticationService.refreshToken"),
                "userId": .string(userId),
            ]
        )
    }

    private func sendLogoutEvent(userId: UUID) async throws {
        try messageService.sendDiscordWebhookAppEvent(
            input: userId.uuidString,
            event: "is logging out",
            logger: config.logger
        )
    }

    private func logLogout(userId: UUID) {
        config.logger.info(
            "Logging user out",
            metadata: [
                "to": .string("AuthenticationService.refreshToken"),
                "userId": .string(userId.uuidString),
            ]
        )
    }

    private func checkUserExists(phoneNumber: String) async throws -> Bool {
        try await UserModel
            .query(on: config.readDb)
            .filter(\.$phoneNumber == phoneNumber)
            .first() != nil
    }

    private func logUserExistenceError(phoneNumber: String, error: Error) {
        config.logger.error(
            "Error checking if user exists.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "phoneNumber": .string(phoneNumber),
                "error": .string("\(error.localizedDescription)"),
            ]
        )
    }
}

internal protocol AuthenticationService {
    var helper: AuthenticationServiceHelper { get }
    var messageService: MessageService { get }
}

internal protocol AuthenticationServiceConfig {
    var writeDb: Database { get }
    var readDb: Database { get }
    var logger: Logger { get }
}

internal struct RootAuthenticationServiceConfig: AuthenticationServiceConfig {
    let writeDb: Database
    let readDb: Database
    let logger: Logger
}
