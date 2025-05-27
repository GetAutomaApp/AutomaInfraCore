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

        helper = .init(
            writeDb: config.writeDb,
            readDb: config.readDb,
            logger: config.logger,
            messageService: messageService
        )
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

        // Log the sending of the verification code
        config.logger.info(
            "Sending verification code to user",
            metadata: [
                "to": .string("AuthenticationService.sendAuthCode"),
                "phoneNumber": .string(phoneNumber),
                "code": .string(code),
            ]
        )

        let distance = try await helper.getDistance()
        let dateToCheck = Date()

        // Check if a recent code was sent
        if
            let mostRecentCodeSent = try await AuthenticationCodeModel
            .query(on: config.readDb)
            .filter(\.$createdAt > dateToCheck.addingTimeInterval(-distance))
            .filter(\.$phoneNumber == phoneNumber)
            .first()
        {
            let timeout = distance - (mostRecentCodeSent.createdAt?.distance(to: dateToCheck) ?? distance)
            return .init(success: timeout == 0, timeout: timeout)
        }

        let codeModelId = UUID()

        do {
            // Send the authentication code
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

    // 4. Refresh Token
    /// Refreshes the access token for a user.
    /// - Parameters:
    ///   - userId: The user ID.
    ///   - signer: The JWT signer.
    /// - Returns: A new access token.
    /// - Throws: Throws an error if refreshing the token fails.
    public func refreshToken(userId: String, signer: Request.JWT) async throws -> String {
        do {
            // Send a Discord webhook event for token refresh
            try messageService
                .sendDiscordWebhookAppEvent(
                    input: userId,
                    event: "is refreshing their access token",
                    logger: config.logger
                )

            // Log the token refresh
            config.logger.info(
                "Refreshing user access token",
                metadata: [
                    "to": .string("AuthenticationService.refreshToken"),
                    "userId": .string(userId),
                ]
            )

            // Generate and return a new access token
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
    /// Logs out a user by deleting old tokens.
    /// - Parameter userId: The user ID.
    /// - Throws: Throws an error if logout fails.
    public func logout(userId: UUID) async throws {
        // Send a Discord webhook event for logout
        try messageService
            .sendDiscordWebhookAppEvent(
                input: userId.uuidString,
                event: "is logging out",
                logger: config.logger
            )

        // Log the user logout
        config.logger.info(
            "Logging user out",
            metadata: [
                "to": .string("AuthenticationService.refreshToken"),
                "userId": .string(userId.uuidString),
            ]
        )

        let concurrencySafeHelper = AuthenticationServiceHelper(
            writeDb: config.writeDb,
            readDb: config.readDb,
            logger: config.logger,
            messageService: messageService
        )
        async let deleteRefresh: () = concurrencySafeHelper.deleteOldTokens(userId: userId, subject: .refresh)
        async let deleteAccess: () = concurrencySafeHelper.deleteOldTokens(userId: userId, subject: .access)

        _ = try await (deleteRefresh, deleteAccess)
    }

    /// Checks if a user exists by phone number.
    /// - Parameter phoneNumber: The phone number to check.
    /// - Returns: A boolean indicating if the user exists.
    /// - Throws: Throws an error if the check fails.
    public func doesUserExist(phoneNumber: String) async throws -> Bool {
        do {
            // Query the user by phone number
            // swiftlint:disable contains_over_first_not_nil
            let exists = try await UserModel
                .query(on: config.readDb)
                .filter(\.$phoneNumber == phoneNumber)
                .first() != nil
            // swiftlint:enable contains_over_first_not_nil

            if exists {
                BackendMetric.totalUsersAlreadyExists.increment()
                return true
            }
            return false
        } catch {
            // Log the error for checking user existence
            config.logger.error(
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
