// MetricsService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

//
//  metrics.swift
//  Backend
//
//  Created by Simon Ferns on 12/30/24.
//
import FlyingFox
import Foundation
import Metrics
import Prometheus

struct MetricsService {
    static let global = MetricsService()

    private var prometheus: PrometheusCollectorRegistry

    private init() {
        let prometheusRegistry = PrometheusCollectorRegistry()
        let myProm = PrometheusMetricsFactory(registry: prometheusRegistry)
        MetricsSystem.bootstrap(myProm)

        prometheus = prometheusRegistry
    }

    func emit() -> Data {
        var buffer = [UInt8]()
        prometheus.emit(into: &buffer)
        let data = String(decoding: buffer, as: Unicode.UTF8.self)
        return Data(data.utf8)
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

enum BackendMetric {
    static let totalSuccessfulVerificationCodesSent = MetricsService.global.makeCounter(
        name: "total_verification_codes_sent",
        labels: ["status": "success"]
    )

    static let totalFailedVerificationCodesSent = MetricsService.global.makeCounter(
        name: "total_verification_codes_sent",
        labels: ["status": "fail"]
    )

    static let totalUsersCreated = MetricsService.global.makeCounter(
        name: "total_users_created",
        labels: ["status": "success"]
    )

    static let totalUsersAlreadyExists = MetricsService.global.makeCounter(
        name: "total_users_created",
        labels: ["status": "alreadyExists"]
    )

    static let totalSuccessfulTokensRefreshed = MetricsService.global.makeCounter(
        name: "total_token_refresh_attempts",
        labels: ["status": "success"]
    )

    static let totalFailedTokensRefreshed = MetricsService.global.makeCounter(
        name: "total_token_refresh_attempts",
        labels: ["status": "fail"]
    )

    static let totalLogoutAttempted = MetricsService.global.makeCounter(
        name: "total_logout_attempts",
        labels: ["status": "success"]
    )

    static let totalFailedLogoutAttempted = MetricsService.global.makeCounter(
        name: "total_logout_attempts",
        labels: ["status": "fail"]
    )

    static let totalProfilePicturesGenerated = MetricsService.global.makeCounter(
        name: "total_profile_pictures_generated",
        labels: [
            "status": "success",
        ]
    )

    static let totalProfilePicturesGenerationFailed = MetricsService.global.makeCounter(
        name: "total_profile_pictures_generated",
        labels: [
            "status": "fail",
        ]
    )

    static let totalTextMessagesSent = MetricsService.global.makeCounter(
        name: "total_text_messages_sent",
        labels: [
            "status": "success",
        ]
    )

    static let totalTextMessagesSentFailed = MetricsService.global.makeCounter(
        name: "total_text_messages_sent",
        labels: [
            "status": "fail",
        ]
    )

    static let totalDiscordWebhookMessagesSent = MetricsService.global.makeCounter(
        name: "total_discord_webhook_messages_sent",
        labels: [
            "status": "success",
        ]
    )

    static let openaiImageGenerationRequests = MetricsService.global.makeCounter(
        name: "openai_image_generation_requests"
    )

    static let totalMediaFilesUploadedToTigris = MetricsService.global.makeCounter(
        name: "total_media_files_uploaded_to_tigris",
        labels: [
            "status": "success",
        ]
    )

    static let totalMediaFilesUploadedToTigrisFailed = MetricsService.global.makeCounter(
        name: "total_media_files_uploaded_to_tigris",
        labels: [
            "status": "fail",
        ]
    )
}
