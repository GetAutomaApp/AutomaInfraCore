// MessageService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Foundation

import SotoSNS
import Vapor

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// Service for handling message-related operations.
internal struct MessageService: Decodable {
    /// Sends an SMS message to a specified phone number.
    /// - Parameters:
    ///   - phoneNumber: The phone number to send the message to.
    ///   - message: The content of the message.
    ///   - logger: The logger for logging messages.
    /// - Returns: The message ID if the message is sent successfully.
    /// - Throws: Throws an error if sending the message fails.
    public func sendSmS(
        to phoneNumber: String,
        message: String,
        logger: Logger
    ) async throws -> String {
        do {
            let clientAuth = try AWSClient(
                credentialProvider: .static(
                    accessKeyId: Environment.getOrThrow("AWS_ACCESS_KEY_ID"),
                    secretAccessKey: Environment.getOrThrow("AWS_SECRET_ACCESS_KEY")
                )
            )

            let region = try Environment.getOrThrow("AWS_DEFAULT_REGION")
            let client = SNS(client: clientAuth, region: .other(region))

            // Publish the message to the specified phone number
            let output = try await client.publish(.init(message: message, phoneNumber: phoneNumber))

            // Send a Discord webhook event for the message
            try sendDiscordWebhookAppEvent(
                input: "random -> \(phoneNumber)",
                event: "sending message: `\(message)`",
                logger: logger
            )

            if let messageId = output.messageId {
                // Log the successful sending of the message
                logger.info(
                    "Sent sms message to user",
                    metadata: [
                        "to": .string("MessageService.sendSmS"),
                        "messageId": .string(messageId),
                        "phoneNumber": .string(phoneNumber),
                        "message": .string(message),
                        "sequenceNumber": .string(output.sequenceNumber ?? ""),
                    ]
                )
                BackendMetric.totalTextMessagesSent.increment()
                return messageId
            } else {
                // Log the failure to send the message
                logger.error(
                    "Failed to send message to user",
                    metadata: [
                        "to": .string("MessageService.sendSmS"),
                        "phoneNumber": .string(phoneNumber),
                        "message": .string(message),
                    ]
                )
                throw GenericErrors.smsMessageFailed
            }
        } catch {
            // Log the error for failed message sending
            logger.error(
                "Failed to send message",
                metadata: [
                    "to": .string("MessageService.sendSmS"),
                    "phoneNumber": .string(phoneNumber),
                    "message": .string(message),
                    "error": .string(error.localizedDescription),
                ]
            )
            BackendMetric.totalTextMessagesSentFailed.increment()
            throw error
        }
    }

    /// Sends a Discord webhook message.
    /// - Parameters:
    ///   - webhookURL: The URL of the webhook to send the message to.
    ///   - message: The message to send.
    ///   - logger: The logger for logging messages.
    /// - Throws: Throws an error if sending the webhook message fails.
    public func sendWebhookMessage(webhookURL: URL, message: DiscordWebhookMessage, logger: Logger) async throws {
        BackendMetric.totalDiscordWebhookMessagesSent.increment()

        if try Environment.getOrThrow("ENVIRONMENT") == "local" {
            return
        }

        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(message)

            var request = URLRequest(url: webhookURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            // Send the request and receive the response
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 204 {
                throw GenericErrors.discordWebhookMessageFailed
            }

            // Log the successful sending of the webhook message
            logger.info(
                "Sent Discord webhook message successfully",
                metadata: [
                    "to": .string("MessageService.sendWebhookMessage"),
                    "webhook": .string(webhookURL.absoluteString),
                    "response": .string(String(data: data, encoding: .utf8) ?? ""),
                ]
            )

        } catch {
            // Log the error for failed webhook message sending
            logger.error(
                "Failed to send Discord webhook message",
                metadata: [
                    "to": .string("MessageService.sendWebhookMessage"),
                    "webhook": .string(webhookURL.absoluteString),
                    "error": .string(error.localizedDescription),
                ]
            )
            throw GenericErrors.discordWebhookMessageFailed
        }
    }

    /// Sends a Discord webhook event for application events.
    /// - Parameters:
    ///   - input: The input string for the event.
    ///   - event: The event description.
    ///   - imageUrl: Optional URL for an image to include in the event.
    ///   - logger: The logger for logging messages.
    ///   - withUrl: The URL of the webhook to send the event to.
    /// - Throws: Throws an error if sending the webhook event fails.
    public func try sendDiscordWebhookAppEvent(
        input: String,
        event: String,
        imageUrl: String? = nil,
        logger: Logger,
        withUrl: URL? = URL(
            string: Environment.getOrThrow("DISCORD_APP_EVENTS_URL")
        )
    ) throws {
        guard
            let withUrl
        else {
            logger.error(
                "Could not send discord webhook, because 'withUrl' is nil.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "event": .string(event),
                    "input": .string(input),
                ]
            )
            throw Abort(.internalServerError)
        }
        Task.detachedLogOnError(destination: "MessageService.sendDiscordWebhookAppEvent", logger: logger) {
            try await sendWebhookMessage(
                webhookURL: withUrl,
                message: MessageFormatterService
                    .craftUserEventDiscordWebhookMessage(
                        input: input,
                        event: event,
                        imageUrl: imageUrl
                    ),
                logger: logger
            )
        }
    }

    /// Sends a Discord alert for critical errors.
    /// - Parameters:
    ///   - alertTitle: The title of the alert.
    ///   - error: The error that occurred.
    ///   - logger: The logger for logging messages.
    /// - Throws: Throws an error if sending the alert fails.
    public func sendDiscordAlert(
        alertTitle: String,
        error: Error,
        logger: Logger
    ) throws {
        guard
            let withUrl = URL(string: Environment.getOrThrow("DISCORD_AUTOMA_ALERTS_WEBHOOK_URL"))
        else {
            logger.error(
                "Could not send discord webhook, because 'withUrl' is nil.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "alert_title": .string(alertTitle),
                ]
            )
            throw Abort(.internalServerError)
        }

        try sendDiscordWebhookAppEvent(
            input: "Critical Error Occurred - \(alertTitle)",
            event: "\(error) - \(error.localizedDescription)",
            logger: logger,
            withUrl: withUrl
        )
    }
}
