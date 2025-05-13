// TransactionalMessageAsyncJob.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation
import Queues
import Vapor

/// Input payload for the transactional message job.
struct TransactionalMessageJobInput: Codable {
    /// The content of the message.
    public let content: String
    /// The phone number to send the message to.
    public let toPhoneNumber: String
}

/// Asynchronous job to send a transactional message.
struct TransactionalMessageAsyncJob: AsyncJob {
    public typealias Payload = TransactionalMessageJobInput

    /// Processes the job to send a transactional message.
    /// - Parameters:
    ///   - context: The queue context.
    ///   - payload: The input payload containing message data.
    /// - Throws: Throws an error if the message sending fails.
    public func dequeue(_ context: QueueContext, _ payload: TransactionalMessageJobInput) async throws {
        let messageService = MessageService()

        // Send the SMS message
        _ = try await messageService
            .sendSmS(
                to: payload.toPhoneNumber,
                message: payload.content,
                logger: context.logger
            )
    }

    /// Handles errors that occur during the job processing.
    /// - Parameters:
    ///   - context: The queue context.
    ///   - error: The error that occurred.
    ///   - payload: The input payload containing message data.
    /// - Throws: Throws an error if logging fails.
    public func error(_ context: QueueContext, _ error: Error, _ payload: TransactionalMessageJobInput) throws {
        // Log the error details
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
