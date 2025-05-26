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
        
        helper = .init(writeDb: config.writeDb, readDb: config.readDb, logger: config.logger, messageService: messageService)
    }
    
    func register(_ payload: UserRegistrationPayload) async throws -> AuthenticationTokensPayloadDTO  {
        var registrator = UserRegistrationService(.init(writeDb: self.config.writeDb, readDb: self.config.readDb, logger: self.config.logger, payload: payload))
        return try await registrator.register()
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
        // Validate and delete the authentication code
        try await helper.validateAndDeleteCode(payload)

        // Query the user by phone number
        let user = try await UserModel
            .query(on: config.readDb)
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
                    logger: config.logger
                )

            // Log the user login
            config.logger.info(
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
            config.logger.error(
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

internal struct UserRegistrationService: AuthenticationService {
    var config: UserRegistrationConfig
    let helper: AuthenticationServiceHelper
    let messageService = MessageService()
    let identifier: UserIdentifier
    var user: UserModel

    public init(_ config: UserRegistrationConfig) {
        self.config = config
        self.helper = .init(writeDb: config.writeDb, readDb: config.readDb, logger: config.logger, messageService: messageService)
        self.identifier = Self.generateNewUserIdentifier()
        self.user = Self.createUserModel(identifier: identifier, config: config)
    }

    public mutating func register() async throws -> AuthenticationTokensPayloadDTO {
        try await helper.validateAndDeleteCode(config.payload.authCodePayload)

        try await generateUserProfilePicture(&user)
        try sendTelemetryDataOnRegistrationSuccess()

        return try await helper.createAuthenticationTokensPayload(
            userId: identifier.id.uuidString,
            signer: config.payload.signer
        )
    }

    private func sendTelemetryDataOnRegistrationSuccess() throws {
        BackendMetric.totalUsersCreated.increment()

        config.logger.info(
            "Successfully Registered User",
            metadata: [
                "to": .string("AuthenticationService.register"),
                "userIdentifier": .string(String(reflecting: identifier))
            ]
        )

        try messageService
            .sendDiscordWebhookAppEvent(
                input: "\(config.payload.authCodePayload.phoneNumber) - \(identifier.id)",
                event: "created an account with \(identifier.name)",
                logger: config.logger
            )
    }

    private static func createUserModel(identifier: UserIdentifier, config: UserRegistrationConfig) -> UserModel {
        UserModel(
            id: identifier.id,
            username: identifier.name,
            phoneNumber: config.payload.authCodePayload.phoneNumber,
            accepted: false
        )
    }

    private func generateUserProfilePicture(_ user: inout UserModel) async throws {
        let userDTO = try user.toDTO(logger: config.logger)
        let profilePictureKey = try ProfilePictureService(logger: config.logger).generateImageKey(for: userDTO)

        try await config.payload.queue.dispatch(ProfilePictureAsyncJob.self, .init(payload: userDTO))

        user.profilePictureKey = profilePictureKey

        try await user.save(on: config.writeDb)
    }

    private static func generateNewUserIdentifier() -> UserIdentifier {
        .init(
            name: RandomService.randomUsername(),
            id: UUID()
        )
    }

    internal struct UserIdentifier: Content {
        let name: String
        let id: UUID
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

struct UserRegistrationConfig: AuthenticationServiceConfig {
    let writeDb: Database
    let readDb: Database
    let logger: Logger
    let payload: UserRegistrationPayload
}

struct UserRegistrationPayload {
    let authCodePayload: AuthPhoneCodePayloadDTO
    let signer: Request.JWT
    let queue: Queue
}

