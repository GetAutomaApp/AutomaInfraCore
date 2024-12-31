// metrics.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

//
//  metrics.swift
//  Backend
//
//  Created by Simon Ferns on 12/30/24.
//
import Metrics
import Prometheus

struct MetricsInitializer {
    static let global = MetricsInitializer()

    private var prometheus: PrometheusCollectorRegistry

    private init() {
        let prometheusRegistry = PrometheusCollectorRegistry()
        let myProm = PrometheusMetricsFactory(registry: prometheusRegistry)
        MetricsSystem.bootstrap(myProm)

        prometheus = prometheusRegistry
    }

    func emit() -> String {
        var buffer = [UInt8]()
        prometheus.emit(into: &buffer)
        return String(decoding: buffer, as: Unicode.UTF8.self)
    }

    func makeCounter(name: String, labels: [String: String] = [:]) -> Prometheus.Counter {
        prometheus
            .makeCounter(
                name: name,
                labels: convertStringDictionaryToStringMap(labels)
            )
    }

    private func convertStringDictionaryToStringMap(_ dictionary: [String: String]) -> [(String, String)] {
        zip(dictionary.keys, dictionary.values).map { ($0.0, $0.1) }
    }
}

enum BackendMetrics {
    static let totalSuccessfulVerificationCodesSent = MetricsInitializer.global.makeCounter(
        name: "total_verification_codes_sent",
        labels: ["status": "success"]
    )

    static let totalFailedVerificationCodesSent = MetricsInitializer.global.makeCounter(
        name: "total_verification_codes_sent",
        labels: ["status": "fail"]
    )

    static let totalUsersCreated = MetricsInitializer.global.makeCounter(
        name: "total_users_created",
        labels: ["status": "success"]
    )

    static let totalUsersAlreadyExists = MetricsInitializer.global.makeCounter(
        name: "total_users_created",
        labels: ["status": "alreadyExists"]
    )

    static let totalSuccessfulTokensRefreshed = MetricsInitializer.global.makeCounter(
        name: "total_token_refresh_attempts",
        labels: ["status": "success"]
    )

    static let totalFailedTokensRefreshed = MetricsInitializer.global.makeCounter(
        name: "total_token_refresh_attempts",
        labels: ["status": "fail"]
    )

    static let totalLogoutAttempted = MetricsInitializer.global.makeCounter(
        name: "total_logout_attempts",
        labels: ["status": "success"]
    )

    static let totalFailedLogoutAttempted = MetricsInitializer.global.makeCounter(
        name: "total_logout_attempts",
        labels: ["status": "fail"]
    )

    static let totalProfilePicturesGenerated = MetricsInitializer.global.makeCounter(
        name: "total_profile_pictures_generated",
        labels: [
            "status": "success",
        ]
    )

    static let totalProfilePicturesGenerationFailed = MetricsInitializer.global.makeCounter(
        name: "total_profile_pictures_generated",
        labels: [
            "status": "fail",
        ]
    )

    static let totalTextMessagesSent = MetricsInitializer.global.makeCounter(
        name: "total_text_messages_sent",
        labels: [
            "status": "success",
        ]
    )

    static let totalTextMessagesSentFailed = MetricsInitializer.global.makeCounter(
        name: "total_text_messages_sent",
        labels: [
            "status": "fail",
        ]
    )

    static let totalDiscordWebhookMessagesSent = MetricsInitializer.global.makeCounter(
        name: "total_discord_webhook_messages_sent",
        labels: [
            "status": "success",
        ]
    )

    static let openaiImageGenerationRequests = MetricsInitializer.global.makeCounter(
        name: "openai_image_generation_requests"
    )

    static let totalMediaFilesUploadedToTigris = MetricsInitializer.global.makeCounter(
        name: "total_media_files_uploaded_to_tigris",
        labels: [
            "status": "success",
        ]
    )

    static let totalMediaFilesUploadedToTigrisFailed = MetricsInitializer.global.makeCounter(
        name: "total_media_files_uploaded_to_tigris",
        labels: [
            "status": "fail",
        ]
    )
}
