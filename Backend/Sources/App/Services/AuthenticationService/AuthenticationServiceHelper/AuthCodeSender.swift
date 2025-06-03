// AuthCodeSender.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import JWT
import Queues
import Vapor

internal struct AuthCodeSender {
    private let config: AuthCodeSenderConfig

    init(_ config: AuthCodeSenderConfig) {
        self.config = config
    }

    public func send() async throws -> AuthenticationCodeResponseDTO {
        try await startSendCodeJob()
        try await createAuthCodeModel()
        sendTelemetryDataOnSendSuccess()
        return sendSuccess()
    }

    private func sendSuccess() -> AuthenticationCodeResponseDTO {
        .init(success: true, timeout: 60)
    }

    private func sendTelemetryDataOnSendSuccess() {
        config.logger.info(
            "Sent verification code to user",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "phoneNumber": .string(config.payload.phoneNumber),
                "code": .string(config.payload.code),
                "codeId": .string(config.payload.codeModelId.uuidString),
            ]
        )

        BackendMetric.totalSuccessfulVerificationCodesSent.increment()
    }

    private func createAuthCodeModel() async throws {
        try await AuthenticationCodeModel(
            id: config.payload.codeModelId,
            code: config.payload.code,
            phoneNumber: config.payload.phoneNumber,
            deletedAt: getCodeDeletionTime()
        ).save(on: config.writeDb)
    }

    private func startSendCodeJob() async throws {
        try await config.queue.dispatch(
            TransactionalMessageAsyncJob.self,
            .init(
                content: MessageFormatterService
                    .craftVerificationCodeMessage(
                        code: config.payload.code
                    ),
                toPhoneNumber: config.payload.phoneNumber
            )
        )
    }

    private func getCodeDeletionTime() -> Date {
        Date().addingTimeInterval(15 * 60)
    }
}

internal struct AuthCodeSenderConfig: AuthenticationServiceConfig {
    let writeDb: Database
    let readDb: Database
    let logger: Logger
    let queue: Queue
    let payload: SendAuthCodePayload
}

internal struct SendAuthCodePayload {
    let code: String
    let phoneNumber: String
    let codeModelId: UUID
}
