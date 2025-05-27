//
//  UserLoginService.swift
//  Backend
//
//  Created by William Ferns on 2025/05/26.
//

import DataTypes
import Vapor
import Fluent
import JWT

internal struct UserLoginService: AuthenticationService {
    var helper: AuthenticationServiceHelper
    let config: UserLoginConfig

    var messageService = MessageService()
    
    init(_ config: UserLoginConfig) {
        self.config = config
        helper = .init(
            writeDb: config.writeDb,
            readDb: config.readDb,
            logger: config.logger,
            messageService: messageService
        )
    }
    
    func login() async throws -> AuthenticationTokensPayloadDTO {
        let authCodePayload = config.payload.authCodePayload
        // Validate and delete the authentication code
        try await helper.validateAndDeleteCode(authCodePayload)

        // Query the user by phone number
        let user = try await UserModel
            .query(on: config.readDb)
            .filter(
                \.$phoneNumber == authCodePayload.phoneNumber
            )
            .first()

        if let user, let userId = user.id?.uuidString {
            // Send a Discord webhook event for login
            try messageService
                .sendDiscordWebhookAppEvent(
                    input: "\(authCodePayload.phoneNumber) - \(user.username)",
                    event: "logging in with code: `\(authCodePayload.code)`",
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
                signer: config.payload.signer
            )
        } else {
            // Log the error for non-existent user
            config.logger.error(
                "Can't login non-existent user",
                metadata: [
                    "to": .string("AuthenticationService.login"),
                    "config": .string(String(describing: config.payload)),
                ]
            )
            throw GenericErrors.userNotFound
        }
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
