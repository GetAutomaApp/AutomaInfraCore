// MessageService.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AWSSNS
import Fluent
import Vapor

enum MessageServiceErrors: Error {
    case discordWebhookMessageFailed
    case smsMessageFailed
}

struct MessageService: Decodable {
    func sendSmS(
        to phoneNumber: String,
        from fromPhoneNumber: String? = nil,
        message: String,
        snsRegion: String = "us-east-1",
        logger: Logger
    ) async throws -> String {
        let client = try SNSClient(region: snsRegion)

        // if let fromPhoneNumber {
        //     // TODO: We don't currently have a persistent phone number setup
        //     return ""
        // }

        print("\(String(describing: fromPhoneNumber))")

        let output = try await client.publish(input: .init(
            message: message,
            phoneNumber: phoneNumber
        ))

        try sendDiscordWebhookAppEvent(
            input: "\(fromPhoneNumber ?? "random") -> \(phoneNumber)",
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
            throw MessageServiceErrors.smsMessageFailed
        }
    }

    func sendWebhookMessage(webhookURL: URL, message: DiscordWebhookMessage, logger: Logger) async throws {
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(message)

            var request = URLRequest(url: webhookURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 204 {
                throw MessageServiceErrors.discordWebhookMessageFailed
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
                    "to": .string("MessageService.sendSmS"),
                    "webhook": .string(webhookURL.absoluteString),
                    "error": .string(error.localizedDescription),
                ]
            )
            throw MessageServiceErrors.discordWebhookMessageFailed
        }
    }

    func sendDiscordWebhookAppEvent(
        input: String,
        event: String,
        imageUrl: String? = nil,
        logger: Logger
    ) throws {
        Task.detached {
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
