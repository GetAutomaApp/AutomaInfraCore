// UserRegistrationService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import JWT
import Queues
import Vapor

internal struct UserRegistrationService: AuthenticationService {
    var config: UserRegistrationConfig
    let helper: AuthenticationServiceHelper
    let messageService = MessageService()
    let identifier: UserIdentifier
    var user: UserModel

    public init(_ config: UserRegistrationConfig) {
        self.config = config
        helper = .init(.init(writeDb: config.writeDb, readDb: config.readDb, logger: config.logger))
        identifier = Self.generateNewUserIdentifier()
        user = Self.createUserModel(identifier: identifier, config: config)
    }

    public mutating func register() async throws -> AuthenticationTokensPayloadDTO {
        try await helper.validateAndDeleteCode(config.payload.authCodePayload)

        try await generateUserProfilePicture(&user)
        try sendTelemetryDataOnRegistrationSuccess()

        return try await helper.createAuthenticationTokensPayload(
            userId: identifier.id,
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
