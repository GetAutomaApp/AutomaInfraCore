// TransactionalMessageActivities.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation
import Temporal
import Vapor

/// Input payload for send transactional message activity.
internal struct SendTransactionalMessageActivityInput: Codable {
    /// The content of the message.
    public let content: String
    /// The phone number to send the message to.
    public let toPhoneNumber: String
}

/// Activites for sending a transactional message.
@ActivitiesContainer
internal struct TransactionalMessageActivities {
    /// Activity for sending a transactional message.
    /// - Parameters:
    ///   - payload: The input payload containing message data.
    /// - Throws: Throws an error if the message sending fails.
    @Activity
    public func sendMessage(app: any Application, payload: SendTransactionalMessageActivityInput) async throws {
        let logger = app.logger
        let snsService = SNSService()

        // Send the SMS message
        do {
            _ = try await snsService
                .sendSmS(
                    to: payload.toPhoneNumber,
                    message: payload.content,
                    logger: logger
                )
        } catch {
            // Capture the current stack trace
            let stackTrace = Thread.callStackSymbols.joined(separator: "\n")

            logger.info(
                "Error occurred while processing activity",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "error": .string(error.localizedDescription),
                    "payload": .string("\(payload.content)"),
                    "stackTrace": .string(stackTrace),
                ]
            )
        }
    }
}
