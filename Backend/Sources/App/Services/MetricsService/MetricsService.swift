// MetricsService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

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
        labels: ["status": MetricStatus.success.rawValue]
    )

    static let totalFailedVerificationCodesSent = MetricsService.global.makeCounter(
        name: "total_verification_codes_sent",
        labels: ["status": MetricStatus.fail.rawValue]
    )

    static let totalUsersCreated = MetricsService.global.makeCounter(
        name: "total_users_created",
        labels: ["status": MetricStatus.success.rawValue]
    )

    static let totalUsersAlreadyExists = MetricsService.global.makeCounter(
        name: "total_users_created",
        labels: ["status": MetricStatus.alreadyExists.rawValue]
    )

    static let totalSuccessfulTokensRefreshed = MetricsService.global.makeCounter(
        name: "total_token_refresh_attempts",
        labels: ["status": MetricStatus.success.rawValue]
    )

    static let totalFailedTokensRefreshed = MetricsService.global.makeCounter(
        name: "total_token_refresh_attempts",
        labels: ["status": MetricStatus.fail.rawValue]
    )

    static let totalLogoutAttempted = MetricsService.global.makeCounter(
        name: "total_logout_attempts",
        labels: ["status": MetricStatus.success.rawValue]
    )

    static let totalFailedLogoutAttempted = MetricsService.global.makeCounter(
        name: "total_logout_attempts",
        labels: ["status": MetricStatus.fail.rawValue]
    )

    static let totalProfilePicturesGenerated = MetricsService.global.makeCounter(
        name: "total_profile_pictures_generated",
        labels: [
            "status": MetricStatus.success.rawValue,
        ]
    )

    static let totalProfilePicturesGenerationFailed = MetricsService.global.makeCounter(
        name: "total_profile_pictures_generated",
        labels: [
            "status": MetricStatus.fail.rawValue,
        ]
    )

    static let totalTextMessagesSent = MetricsService.global.makeCounter(
        name: "total_text_messages_sent",
        labels: [
            "status": MetricStatus.success.rawValue,
        ]
    )

    static let totalTextMessagesSentFailed = MetricsService.global.makeCounter(
        name: "total_text_messages_sent",
        labels: [
            "status": MetricStatus.fail.rawValue,
        ]
    )

    static let totalDiscordWebhookMessagesSent = MetricsService.global.makeCounter(
        name: "total_discord_webhook_messages_sent",
        labels: [
            "status": MetricStatus.success.rawValue,
        ]
    )

    static let openAIImageGenerationRequests = MetricsService.global.makeCounter(
        name: "openai_image_generation_requests"
    )

    static func openAIImageGenerationRequest(
        status: MetricStatus
    ) -> Prometheus.Counter {
        MetricsService.global.makeCounter(
            name: "openai_image_generation_requests",
            labels: [
                "status": status.rawValue,
            ]
        )
    }

    // static let totalTweetPostsSent = MetricsService.global.makeCounter(
    //     name: "total_tweet_posts_sent",
    //     labels: [
    //         "status": MetricStatus.success.rawValue,
    //     ]
    // )

    /// Creates a counter to track Twitter OAuth request metrics
    /// - Parameter status: The status of the OAuth request (success/fail/etc)
    /// - Returns: A Prometheus counter for Twitter OAuth requests with the given status
    static func twitterOAuthRequest(
        status: MetricStatus
    ) -> Prometheus.Counter {
        MetricsService.global.makeCounter(
            name: "twitter_oauth_requests",
            labels: [
                "status": status.rawValue,
            ]
        )
    }

    /// Creates a counter to track Twitter user token conversion metrics
    /// - Parameter status: The status of the token conversion (success/fail/etc)
    /// - Returns: A Prometheus counter for Twitter token conversions with the given status
    static func twitterUserTokensConverted(
        status: MetricStatus
    ) -> Prometheus.Counter {
        MetricsService.global.makeCounter(
            name: "twitter_user_tokens_converted",
            labels: [
                "status": status.rawValue,
            ]
        )
    }

    /// Creates a counter to track Twitter post tweet metrics
    /// - Parameter status: The status of posting the tweet (success/fail/etc)
    /// - Returns: A Prometheus counter for tweet posts with the given status
    static func twitterPostTweet(
        status: MetricStatus
    ) -> Prometheus.Counter {
        MetricsService.global.makeCounter(
            name: "twitter_post_tweet",
            labels: [
                "status": status.rawValue,
            ]
        )
    }

    static func chatCompletionServiceCall(
        platform: ChatCompletionPlatform,
        model: ChatCompletionModel,
        status: MetricStatus
    ) -> Prometheus.Counter {
        MetricsService.global.makeCounter(
            name: "chat_completion_service_call",
            labels: [
                "status": status.rawValue,
                "platform": platform.rawValue,
                "model": model.rawValue,
            ]
        )
    }

    static let totalMediaFilesUploadedToTigris = MetricsService.global.makeCounter(
        name: "total_media_files_uploaded_to_tigris",
        labels: [
            "status": MetricStatus.success.rawValue,
        ]
    )

    static let totalMediaFilesUploadedToTigrisFailed = MetricsService.global.makeCounter(
        name: "total_media_files_uploaded_to_tigris",
        labels: [
            "status": MetricStatus.fail.rawValue,
        ]
    )

    static func firecrawlScrapeMarkdown(
        status: MetricStatus,
        url: String
    ) -> Prometheus.Counter {
        MetricsService.global.makeCounter(
            name: "firecrawl_markdown_scraping",
            labels: [
                "status": status.rawValue,
                "url": url,
            ]
        )
    }
}
