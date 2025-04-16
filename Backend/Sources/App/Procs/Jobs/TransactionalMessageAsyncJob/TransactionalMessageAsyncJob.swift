// TransactionalMessageAsyncJob.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation
import Queues
import Vapor

internal struct TransactionalMessageJobInput: Codable {
    public let content: String
    public let toPhoneNumber: String
}

internal struct TransactionalMessageAsyncJob: AsyncJob {
    typealias Payload = TransactionalMessageJobInput

    public func dequeue(_ context: QueueContext, _ payload: TransactionalMessageJobInput) async throws {
        let messageService = MessageService()

        _ = try await messageService
            .sendSmS(
                to: payload.toPhoneNumber,
                message: payload.content,
                logger: context.logger
            )
    }

    public func error(_ context: QueueContext, _ error: Error, _ payload: TransactionalMessageJobInput) throws {
        context.logger.info(
            "Error occurred while processing job",
            metadata: [
                "to": .string("TransactionalMessageAsyncJob.dequeue"),
                "error": .string(error.localizedDescription),
                "payload": .string("\(payload.content)"),
            ]
        )
    }
}
