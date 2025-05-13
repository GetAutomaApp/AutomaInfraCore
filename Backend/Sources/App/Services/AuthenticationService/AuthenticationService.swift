// AuthenticationService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import JWT
import Queues
import Vapor

/// Service for handling authentication-related operations.
public struct AuthenticationService {
    /// The database for writing operations.
    public let writeDb: Database
    /// The database for reading operations.
    public let readDb: Database
    /// The logger for logging messages.
    public let logger: Logger
    /// Helper for authentication service operations.
    public let helper: AuthenticationServiceHelper

    /// Initializes a new instance of `AuthenticationService`.
    /// - Parameters:
    ///   - writeDb: The database for writing operations.
    ///   - readDb: The database for reading operations.
    ///   - logger: The logger for logging messages.
    public init(
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
    /// Registers a new user with a specific phone number.
    /// - Parameters:
    ///   - payload: The payload containing phone number and code.
    ///   - signer: The JWT signer.
    ///   - queue: The queue for dispatching jobs.
    /// - Returns: An `AuthenticationTokensPayloadDTO` containing authentication tokens.
    /// - Throws: Throws an error if registration fails.
    public func register(
        payload: AuthPhoneCodePayloadDTO,
        signer: Request.JWT,
        queue: Queue
    ) async throws -> AuthenticationTokensPayloadDTO {
        let messageService = MessageService()
        let profilePictureService = ProfilePictureService(logger: logger)

        // Validate and delete the authentication code
        try await helper.getValidateAndDeleteCode(
            phoneNumber: payload.phoneNumber,
            code: payload.code
        )

        let username = RandomService.randomUsername()
        let userId = UUID()

        // Create a new user
        let user = UserModel(
            id: userId,
            username: username,
            phoneNumber: payload.phoneNumber,
            accepted: false
        )

        let userDTO = try user.toDTO(logger: logger)
        let profilePictureKey = try profilePictureService.generateImageKey(for: userDTO)

        // Dispatch a job to create a profile picture
        try await queue.dispatch(ProfilePictureAsyncJob.self, .init(payload: userDTO))

        user.profilePictureKey = profilePictureKey

        // Save the user to the database
        try await user.save(on: writeDb)

        BackendMetric.totalUsersCreated.increment()

        // Log the successful registration
        logger.info(
            "Successfully Registered User",
            metadata: [
                "to": .string("AuthenticationService.register"),
                "userId": .string(userId.uuidString),
                "username": .string(username),
            ]
        )

        // Send a Discord webhook event
        try messageService
            .sendDiscordWebhookAppEvent(
                input: "\(payload.phoneNumber) - \(userId)",
                event: "created an account with \(username)",
                logger: logger
            )

        // Create and return authentication tokens
        return try await helper.createAuthenticationTokensPayload(
            userId: userId.uuidString,
            signer: signer
        )
    }

    // 2. Send Login Auth Code
    /// Sends a login authentication code to the user.
    /// - Parameters:
    ///   - phoneNumber: The phone number of the user.
    ///   - queue: The queue for dispatching jobs.
    /// - Returns: An `AuthenticationCodeResponseDTO` indicating success and timeout.
    /// - Throws: Throws an error if sending the code fails.
    public func sendAuthCode(phoneNumber: String, queue: Queue) async throws -> AuthenticationCodeResponseDTO {
        let code = RandomService.randomCode()

        // Log the sending of the verification code
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

        // Check if a recent code was sent
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
            // Send the authentication code
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
    /// Logs in a user with a phone number and code.
    /// - Parameters:
    ///   - payload: The payload containing phone number and code.
    ///   - signer: The JWT signer.
    /// - Returns: An `AuthenticationTokensPayloadDTO` containing authentication tokens.
    /// - Throws: Throws an error if login fails.
    public func login(
        payload: AuthPhoneCodePayloadDTO,
        signer: Request.JWT
    ) async throws -> AuthenticationTokensPayloadDTO {
        let messageService = MessageService()

        // Validate and delete the authentication code
        try await helper.getValidateAndDeleteCode(
            phoneNumber: payload.phoneNumber,
            code: payload.code
        )

        // Query the user by phone number
        let user = try await UserModel
            .query(on: readDb)
            .filter(
                \.$phoneNumber == payload.phoneNumber
            )
            .first()

        if let user, let userId = user.id?.uuidString {
            // Send a Discord webhook event for login
            try messageService
                .sendDiscordWebhookAppEvent(
                    input: "\(payload.phoneNumber) - \(user.username)",
                    event: "logging in with code: `\(payload.code)`",
                    logger: logger
                )

            // Log the user login
            logger.info(
                "Logging in user",
                metadata: [
                    "to": .string("AuthenticationService.login"),
                    "userId": .string(userId),
                    "username": .string(user.username),
                ]
            )

            // Create and return authentication tokens
            return try await helper.createAuthenticationTokensPayload(
                userId: userId,
                signer: signer
            )
        } else {
            // Log the error for non-existent user
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
    /// Refreshes the access token for a user.
    /// - Parameters:
    ///   - userId: The user ID.
    ///   - signer: The JWT signer.
    /// - Returns: A new access token.
    /// - Throws: Throws an error if refreshing the token fails.
    public func refreshToken(userId: String, signer: Request.JWT) async throws -> String {
        do {
            let messageService = MessageService()

            // Send a Discord webhook event for token refresh
            try messageService
                .sendDiscordWebhookAppEvent(
                    input: userId,
                    event: "is refreshing their access token",
                    logger: logger
                )

            // Log the token refresh
            logger.info(
                "Refreshing user access token",
                metadata: [
                    "to": .string("AuthenticationService.refreshToken"),
                    "userId": .string(userId),
                ]
            )

            // Generate and return a new access token
            return try await helper.generateAccessToken(
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
    /// Logs out a user by deleting old tokens.
    /// - Parameter userId: The user ID.
    /// - Throws: Throws an error if logout fails.
    public func logout(userId: UUID) async throws {
        let messageService = MessageService()

        // Send a Discord webhook event for logout
        try messageService
            .sendDiscordWebhookAppEvent(
                input: userId.uuidString,
                event: "is logging out",
                logger: logger
            )

        // Log the user logout
        logger.info(
            "Logging user out",
            metadata: [
                "to": .string("AuthenticationService.refreshToken"),
                "userId": .string(userId.uuidString),
            ]
        )

        // Delete old tokens for the user
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

    /// Checks if a user exists by phone number.
    /// - Parameter phoneNumber: The phone number to check.
    /// - Returns: A boolean indicating if the user exists.
    /// - Throws: Throws an error if the check fails.
    public func doesUserExist(phoneNumber: String) async throws -> Bool {
        do {
            // Query the user by phone number
            // swiftlint:disable contains_over_first_not_nil
            let exists = try await UserModel
                .query(on: readDb)
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
