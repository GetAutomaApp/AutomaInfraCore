// MessageService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AWSSNS
import DataTypes
import Fluent
import Foundation
import Vapor

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

struct MessageService: Decodable {
    func sendSmS(
        to phoneNumber: String,
        message: String,
        logger: Logger
    ) async throws -> String {
        do {
            let client = try await SNSClient()

            let output = try await client.publish(input: .init(
                message: message,
                phoneNumber: phoneNumber
            ))

            try sendDiscordWebhookAppEvent(
                input: "random -> \(phoneNumber)",
                event: "sending message: `\(message)`",
                logger: logger
            )

            if let messageId = output.messageId {
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

    func sendWebhookMessage(webhookURL: URL, message: DiscordWebhookMessage, logger: Logger) async throws {
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

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 204 {
                throw GenericErrors.discordWebhookMessageFailed
            }

            logger.info(
                "Sent Discord webhook message successfully",
                metadata: [
                    "to": .string("MessageService.sendWebhookMessage"),
                    "webhook": .string(webhookURL.absoluteString),
                    "response": .string(String(data: data, encoding: .utf8) ?? ""),
                ]
            )

        } catch {
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

    func sendDiscordWebhookAppEvent(
        input: String,
        event: String,
        imageUrl: String? = nil,
        logger: Logger
    ) throws {
        Task.detachedLogOnError(to: "MessageService.sendDiscordWebhookAppEvent", logger: logger) {
            try await sendWebhookMessage(
                webhookURL: URL(string: Environment.get("DISCORD_APP_EVENTS_URL")!)!,
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
}
