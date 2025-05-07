// AuthenticationServiceHelper.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import JWT
import Queues
import Vapor

/// Helper struct for authentication service operations.
internal struct AuthenticationServiceHelper {
    /// The database for writing operations.
    public let writeDb: Database
    /// The database for reading operations.
    public let readDb: Database
    /// The logger for logging messages.
    public let logger: Logger

    /// Validates and deletes an authentication code.
    /// - Parameters:
    ///   - phoneNumber: The phone number associated with the code.
    ///   - code: The authentication code to validate.
    /// - Throws: Throws an error if validation fails.
    public func getValidateAndDeleteCode(phoneNumber: String, code: String) async throws {
        // Log the start of code validation
        logger.info(
            "Starting validation of authentication code",
            metadata: [
                "phoneNumber": .string(phoneNumber),
                "code": .string(code),
                "to": .string("AuthenticationService.getValidateAndDeleteCode"),
            ]
        )

        let messageService = MessageService()

        // Query the valid code by phone number and code
        let validCode = try await AuthenticationCodeModel
            .query(on: readDb)
            .filter(\.$phoneNumber == phoneNumber)
            .filter(\.$code == code.lowercased())
            .first()

        guard let validCode else {
            // Log the error for invalid code
            logger.error(
                "Authentication code is invalid",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "code": .string(code),
                    "phoneNumber": .string(phoneNumber),
                    "validCode": .string(String(describing: validCode)),
                ]
            )
            throw GenericErrors.invalidCode
        }

        // Log the valid code
        logger.info(
            "Authentication code is valid",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "code": .string(code),
                "phoneNumber": .string(phoneNumber),
                "validCode": .string(String(reflecting: validCode)),
            ]
        )

        // Send a Discord webhook event for valid code
        try messageService.sendDiscordWebhookAppEvent(
            input: phoneNumber,
            event: "submitted valid code `\(code)`",
            logger: logger
        )

        // Delete the valid code from the database
        try await validCode.delete(on: writeDb)
    }

    /// Returns the code deletion time.
    /// - Returns: A `Date` representing the code deletion time.
    public func codeDeletionTime() -> Date {
        Date().addingTimeInterval(15 * 60) // Code expires after 15 minutes
    }

    /// Generates an access token for a user.
    /// - Parameters:
    ///   - userId: The user ID.
    ///   - expiresIn: The expiration time for the token.
    ///   - subject: The subject of the token.
    ///   - signer: The JWT signer.
    /// - Returns: A signed JWT token string.
    /// - Throws: Throws an error if token generation fails.
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

        // Sign the token using the JWT signer
        let signedToken = try await signer.sign(token)

        // Delete old tokens for the user
        try await deleteOldTokens(userId: userId, subject: subject, skip: 5)

        let tokenId = UUID()

        // Save the new token to the database
        try await JwtTokenModel(
            id: tokenId,
            token: signedToken,
            userId: userId,
            subject: subject,
            deletedAt: expiresAt
        ).create(on: writeDb)

        return signedToken
    }

    /// Deletes old tokens for a user.
    /// - Parameters:
    ///   - userId: The user ID.
    ///   - subject: The subject of the tokens to delete.
    ///   - skip: The number of tokens to skip before deleting.
    /// - Throws: Throws an error if token deletion fails.
    public func deleteOldTokens(
        userId: UUID,
        subject: JWTTokenSubject,
        skip: Int? = nil
    ) async throws {
        // Log the start of token deletion
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

        // Retrieve tokens to delete
        let tokensToDelete = try await query.all()

        for token in tokensToDelete {
            // Delete each token
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

    /// Creates an authentication tokens payload.
    /// - Parameters:
    ///   - userId: The user ID.
    ///   - signer: The JWT signer.
    /// - Returns: An `AuthenticationTokensPayloadDTO` containing access and refresh tokens.
    /// - Throws: Throws an error if token creation fails.
    public func createAuthenticationTokensPayload(
        userId: String,
        signer: Request.JWT
    ) async throws -> AuthenticationTokensPayloadDTO {
        // Log the start of tokens payload creation
        logger.info(
            "Creating authentication tokens payload",
            metadata: [
                "to": .string("AuthenticationService.createAuthenticationTokensPayload"),
                "userId": .string(userId),
            ]
        )

        let messageService = MessageService()

        // Generate access and refresh tokens
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

        // Log the successful creation of tokens payload
        logger.info(
            "Successfully created authentication tokens payload",
            metadata: [
                "to": .string("AuthenticationService.createAuthenticationTokensPayload"),
                "userId": .string(userId),
                "accessTokenLength": .string("\(accessToken.count)"),
                "refreshTokenLength": .string("\(refreshToken.count)"),
            ]
        )

        // Send a Discord webhook event for tokens creation
        try messageService.sendDiscordWebhookAppEvent(
            input: userId,
            event: "generated tokens: `access: \(accessToken.count)` `refresh: \(refreshToken.count)`",
            logger: logger
        )

        return tokensPayload
    }

    /// Retrieves the distance for authentication code validation.
    /// - Returns: A `Double` representing the distance.
    /// - Throws: Throws an error if retrieval fails.
    public func getDistance() throws -> Double {
        let distanceRawValue = try Environment.getOrThrow("AUTHENTICATION_CODE_DISTANCE")

        guard
            let distance = Double(distanceRawValue)
        else {
            // Log the error for conversion failure
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

    /// Sends an authentication code to a user.
    /// - Parameters:
    ///   - queue: The queue for dispatching jobs.
    ///   - code: The authentication code to send.
    ///   - phoneNumber: The phone number to send the code to.
    ///   - codeModelId: The ID of the code model.
    /// - Returns: An `AuthenticationCodeResponseDTO` indicating success and timeout.
    /// - Throws: Throws an error if sending the code fails.
    public func sendAuthCode(
        queue: Queue,
        code: String,
        phoneNumber: String,
        codeModelId: UUID
    ) async throws -> AuthenticationCodeResponseDTO {
        // Dispatch a job to send the authentication code
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

        // Save the code model to the database
        try await codeModel.save(on: writeDb)

        // Log the successful sending of the code
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

    /// Handles the case where an authentication code was not sent due to a specific error.
    /// - Parameters:
    ///   - code: The authentication code.
    ///   - phoneNumber: The phone number to send the code to.
    ///   - codeModelId: The ID of the code model.
    ///   - error: The specific error that occurred.
    /// - Throws: Throws the provided error.
    public func handleAuthCodeNotSent(
        code: String,
        phoneNumber: String,
        codeModelId: UUID,
        error: GenericErrors
    ) throws {
        BackendMetric.totalFailedVerificationCodesSent.increment()
        // Log the error for failed code sending
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

    /// Handles the case where an authentication code was not sent due to an unknown error.
    /// - Parameters:
    ///   - code: The authentication code.
    ///   - phoneNumber: The phone number to send the code to.
    ///   - codeModelId: The ID of the code model.
    ///   - error: The unknown error that occurred.
    /// - Throws: Throws a generic unknown error.
    public func handleAuthCodeNotSent(
        code: String,
        phoneNumber: String,
        codeModelId: UUID,
        error: any Error
    ) throws {
        BackendMetric.totalFailedVerificationCodesSent.increment()
        // Log the error for failed code sending
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
