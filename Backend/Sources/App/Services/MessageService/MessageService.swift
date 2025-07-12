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

internal struct MessageService: Decodable {
    // MARK: - Public API

    public func sendSmS(
        to phoneNumber: String,
        message: String,
        logger: Logger
    ) async throws -> String {
        do {
            let snsClient = try createSNSClient()
            let output = try await snsClient.publish(.init(message: message, phoneNumber: phoneNumber))

            try await logSmsSentEvent(to: phoneNumber, message: message, logger: logger)

            return try extractMessageId(from: output, phoneNumber: phoneNumber, message: message, logger: logger)
        } catch {
            handleSmsError(error, to: phoneNumber, message: message, logger: logger)
            throw error
        }
    }

    public func sendWebhookMessage(
        webhookURL: URL,
        message: DiscordWebhookMessage,
        logger: Logger
    ) async throws {
        BackendMetric.totalDiscordWebhookMessagesSent.increment()

        guard try Environment.getOrThrow("ENVIRONMENT") != "local" else { return }

        do {
            let request = try buildWebhookRequest(url: webhookURL, message: message)
            let (data, response) = try await URLSession.shared.data(for: request)

            try validateWebhookResponse(response, data: data)

            logger.info("Sent Discord webhook message successfully", metadata: [
                "to": .string("MessageService.sendWebhookMessage"),
                "webhook": .string(webhookURL.absoluteString),
                "response": .string(String(data: data, encoding: .utf8) ?? "")
            ])
        } catch {
            logger.error("Failed to send Discord webhook message", metadata: [
                "to": .string("MessageService.sendWebhookMessage"),
                "webhook": .string(webhookURL.absoluteString),
                "error": .string(error.localizedDescription)
            ])
            throw GenericErrors.discordWebhookMessageFailed
        }
    }

    public func sendDiscordWebhookAppEvent(
        input: String,
        event: String,
        imageUrl: String? = nil,
        logger: Logger,
        withUrl: URL? = nil
    ) throws {
        guard let url = try resolveWebhookURL(override: withUrl, logger: logger, input: input, event: event) else {
            return
        }

        Task.detachedLogOnError(destination: "MessageService.sendDiscordWebhookAppEvent", logger: logger) {
            try await sendWebhookMessage(
                webhookURL: url,
                message: MessageFormatterService.craftUserEventDiscordWebhookMessage(
                    input: input,
                    event: event,
                    imageUrl: imageUrl
                ),
                logger: logger
            )
        }
    }

    public func sendDiscordAlert(
        alertTitle: String,
        error: Error,
        logger: Logger
    ) throws {
        guard
            let webhookUrl = try URL(string: Environment.getOrThrow("DISCORD_AUTOMA_ALERTS_WEBHOOK_URL"))
        else {
            throwWebhookURLError(logger: logger, title: alertTitle)
        }

        try sendDiscordWebhookAppEvent(
            input: "Critical Error Occurred - \(alertTitle)",
            event: "\(error) - \(error.localizedDescription)",
            logger: logger,
            withUrl: webhookUrl
        )
    }

    // MARK: - Private Helpers

    private func createSNSClient() throws -> SNS {
        let clientAuth = try AWSClient(
            credentialProvider: .static(
                accessKeyId: Environment.getOrThrow("AWS_ACCESS_KEY_ID"),
                secretAccessKey: Environment.getOrThrow("AWS_SECRET_ACCESS_KEY")
            )
        )
        let region = try Environment.getOrThrow("AWS_DEFAULT_REGION")
        return SNS(client: clientAuth, region: .other(region))
    }

    private func extractMessageId(
        from output: SNS.PublishResponse,
        phoneNumber: String,
        message: String,
        logger: Logger
    ) throws -> String {
        guard let messageId = output.messageId else {
            logger.error("Failed to send message to user", metadata: [
                "to": .string("MessageService.sendSmS"),
                "phoneNumber": .string(phoneNumber),
                "message": .string(message),
            ])
            throw GenericErrors.smsMessageFailed
        }

        logger.info("Sent SMS message to user", metadata: [
            "to": .string("MessageService.sendSmS"),
            "messageId": .string(messageId),
            "phoneNumber": .string(phoneNumber),
            "message": .string(message),
            "sequenceNumber": .string(output.sequenceNumber ?? "")
        ])
        BackendMetric.totalTextMessagesSent.increment()

        return messageId
    }

    private func handleSmsError(
        _ error: Error,
        to phoneNumber: String,
        message: String,
        logger: Logger
    ) {
        logger.error("Failed to send message", metadata: [
            "to": .string("MessageService.sendSmS"),
            "phoneNumber": .string(phoneNumber),
            "message": .string(message),
            "error": .string(error.localizedDescription)
        ])
        BackendMetric.totalTextMessagesSentFailed.increment()
    }

    private func buildWebhookRequest(url: URL, message: DiscordWebhookMessage) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(message)
        return request
    }

    private func validateWebhookResponse(_ response: URLResponse, data _: Data) throws {
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 204 {
            throw GenericErrors.discordWebhookMessageFailed
        }
    }

    private func resolveWebhookURL(
        override: URL?,
        logger: Logger,
        input: String,
        event: String
    ) throws -> URL? {
        if let url = override {
            return url
        }

        guard let fallbackUrl = try? URL(string: Environment.getOrThrow("DISCORD_APP_EVENTS_URL")) else {
            logger.error("Could not resolve Discord webhook URL", metadata: [
                "to": .string("MessageService.sendDiscordWebhookAppEvent"),
                "event": .string(event),
                "input": .string(input)
            ])
            throw Abort(.internalServerError)
        }

        return fallbackUrl
    }

    private func throwWebhookURLError(logger: Logger, title: String) -> Never {
        logger.error("Could not resolve Discord webhook URL", metadata: [
            "to": .string("MessageService.sendDiscordAlert"),
            "alert_title": .string(title)
        ])
        fatalError("Invalid webhook URL") // Or throw Abort(.internalServerError)
    }

    private func logSmsSentEvent(to phoneNumber: String, message: String, logger: Logger) throws {
        try sendDiscordWebhookAppEvent(
            input: "random -> \(phoneNumber)",
            event: "sending message: `\(message)`",
            logger: logger
        )
    }
}
