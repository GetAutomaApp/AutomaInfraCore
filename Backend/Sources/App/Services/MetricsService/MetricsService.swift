// MetricsService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation
import Metrics
import Prometheus

/// Service for managing and emitting metrics.
struct MetricsService {
    /// Global instance of the `MetricsService`.
    public static let global = Self()

    /// Prometheus collector registry for managing metrics.
    private var prometheus: PrometheusCollectorRegistry

    /// Initializes a new instance of `MetricsService`.
    private init() {
        let prometheusRegistry = PrometheusCollectorRegistry()
        let myProm = PrometheusMetricsFactory(registry: prometheusRegistry)
        MetricsSystem.bootstrap(myProm)

        prometheus = prometheusRegistry
    }

    /// Emits metrics into a buffer and returns the data.
    /// - Returns: A `Data` object containing the emitted metrics.
    public func emit() -> Data {
        var buffer = [UInt8]()
        prometheus.emit(into: &buffer)
        let data = String(decoding: buffer, as: Unicode.UTF8.self)
        return Data(data.utf8)
    }

    /// Creates a counter type metric.
    /// - Parameters:
    ///   - name: The name of the counter.
    ///   - labels: Optional labels for the counter.
    /// - Returns: A `Prometheus.Counter` object.
    public func makeCounter(name: String, labels: [String: String] = [:]) -> Prometheus.Counter {
        prometheus
            .makeCounter(
                name: name,
                labels: convertStringDictionaryToStringMap(labels)
            )
    }

    /// Converts a dictionary of strings to a tuple array.
    /// - Parameter dictionary: The dictionary to convert.
    /// - Returns: An array of tuples representing the dictionary.
    private func convertStringDictionaryToStringMap(_ dictionary: [String: String]) -> [(String, String)] {
        zip(dictionary.keys, dictionary.values).map { ($0.0, $0.1) }
    }
}

/// Enum for managing backend metrics.
enum BackendMetric {
    /// Counter for successful verification codes sent.
    public static let totalSuccessfulVerificationCodesSent = MetricsService.global.makeCounter(
        name: "total_verification_codes_sent",
        labels: ["status": Self.MetricStatus.success.rawValue]
    )

    /// Counter for failed verification codes sent.
    public static let totalFailedVerificationCodesSent = MetricsService.global.makeCounter(
        name: "total_verification_codes_sent",
        labels: ["status": Self.MetricStatus.fail.rawValue]
    )

    /// Counter for total users created.
    public static let totalUsersCreated = MetricsService.global.makeCounter(
        name: "total_users_created",
        labels: ["status": Self.MetricStatus.success.rawValue]
    )

    /// Counter for users that already exist.
    public static let totalUsersAlreadyExists = MetricsService.global.makeCounter(
        name: "total_users_created",
        labels: ["status": Self.MetricStatus.alreadyExists.rawValue]
    )

    /// Counter for successful token refresh attempts.
    public static let totalSuccessfulTokensRefreshed = MetricsService.global.makeCounter(
        name: "total_token_refresh_attempts",
        labels: ["status": Self.MetricStatus.success.rawValue]
    )

    /// Counter for failed token refresh attempts.
    public static let totalFailedTokensRefreshed = MetricsService.global.makeCounter(
        name: "total_token_refresh_attempts",
        labels: ["status": Self.MetricStatus.fail.rawValue]
    )

    /// Counter for logout attempts.
    public static let totalLogoutAttempted = MetricsService.global.makeCounter(
        name: "total_logout_attempts",
        labels: ["status": Self.MetricStatus.success.rawValue]
    )

    /// Counter for failed logout attempts.
    public static let totalFailedLogoutAttempted = MetricsService.global.makeCounter(
        name: "total_logout_attempts",
        labels: ["status": Self.MetricStatus.fail.rawValue]
    )

    /// Counter for profile pictures generated.
    public static let totalProfilePicturesGenerated = MetricsService.global.makeCounter(
        name: "total_profile_pictures_generated",
        labels: [
            "status": Self.MetricStatus.success.rawValue,
        ]
    )

    /// Counter for failed profile picture generation.
    public static let totalProfilePicturesGenerationFailed = MetricsService.global.makeCounter(
        name: "total_profile_pictures_generated",
        labels: [
            "status": Self.MetricStatus.fail.rawValue,
        ]
    )

    /// Counter for text messages sent.
    public static let totalTextMessagesSent = MetricsService.global.makeCounter(
        name: "total_text_messages_sent",
        labels: [
            "status": Self.MetricStatus.success.rawValue,
        ]
    )

    /// Counter for failed text messages sent.
    public static let totalTextMessagesSentFailed = MetricsService.global.makeCounter(
        name: "total_text_messages_sent",
        labels: [
            "status": Self.MetricStatus.fail.rawValue,
        ]
    )

    /// Counter for Discord webhook messages sent.
    public static let totalDiscordWebhookMessagesSent = MetricsService.global.makeCounter(
        name: "total_discord_webhook_messages_sent",
        labels: [
            "status": Self.MetricStatus.success.rawValue,
        ]
    )

    /// Counter for OpenAI image generation requests.
    public static let openAIImageGenerationRequests = MetricsService.global.makeCounter(
        name: "openai_image_generation_requests"
    )

    /// Creates a counter for OpenAI image generation requests.
    /// - Parameter status: The status of the request.
    /// - Returns: A `Prometheus.Counter` object.
    public static func openAIImageGenerationRequest(
        status: Self.MetricStatus
    ) -> Prometheus.Counter {
        MetricsService.global.makeCounter(
            name: "openai_image_generation_requests",
            labels: [
                "status": status.rawValue,
            ]
        )
    }

    /// Creates a counter to track Twitter OAuth request metrics.
    /// - Parameter status: The status of the OAuth request (success/fail/etc).
    /// - Returns: A Prometheus counter for Twitter OAuth requests with the given status.
    public static func twitterOAuthRequest(
        status: Self.MetricStatus
    ) -> Prometheus.Counter {
        MetricsService.global.makeCounter(
            name: "twitter_oauth_requests",
            labels: [
                "status": status.rawValue,
            ]
        )
    }

    /// Creates a counter to track Twitter user token conversion metrics.
    /// - Parameter status: The status of the token conversion (success/fail/etc).
    /// - Returns: A Prometheus counter for Twitter token conversions with the given status.
    public static func twitterUserTokensConverted(
        status: Self.MetricStatus
    ) -> Prometheus.Counter {
        MetricsService.global.makeCounter(
            name: "twitter_user_tokens_converted",
            labels: [
                "status": status.rawValue,
            ]
        )
    }

    /// Creates a counter to track Twitter post tweet metrics.
    /// - Parameter status: The status of posting the tweet (success/fail/etc).
    /// - Returns: A Prometheus counter for tweet posts with the given status.
    public static func twitterPostTweet(
        status: Self.MetricStatus
    ) -> Prometheus.Counter {
        MetricsService.global.makeCounter(
            name: "twitter_post_tweet",
            labels: [
                "status": status.rawValue,
            ]
        )
    }

    /// Creates a counter to track RSS feed reader metrics.
    /// - Parameters:
    ///   - status: The status of the RSS feed read.
    ///   - url: The URL of the RSS feed.
    ///   - isRSSFeed: Optional flag indicating if the URL is an RSS feed.
    ///   - didThrowOnFeedInitialization: Flag indicating if an error occurred during feed initialization.
    /// - Returns: A Prometheus counter for RSS feed reads with the given status.
    public static func rssFeedReaderMetric(
        status: Self.MetricStatus,
        url: URL,
        isRSSFeed: Bool? = nil,
        didThrowOnFeedInitialization: Bool = false
    ) -> Prometheus.Counter {
        let labels = [
            "status": status.rawValue,
            "url": url.absoluteString,
            "is_rss_feed": isRSSFeed.map { $0 ? "true" : "false" } ?? "undefined",
            "did_throw_on_feed_initialization": didThrowOnFeedInitialization ? "true" : "false",
        ]

        return MetricsService.global.makeCounter(
            name: "rss_feed_read_call",
            labels: labels
        )
    }

    /// Creates a counter to track chat completion service calls.
    /// - Parameters:
    ///   - platform: The platform used for chat completion.
    ///   - model: The model used for chat completion.
    ///   - status: The status of the service call.
    /// - Returns: A Prometheus counter for chat completion service calls with the given status.
    public static func chatCompletionServiceCall(
        platform: ChatCompletionPlatform,
        model: ChatCompletionModel,
        status: Self.MetricStatus
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

    /// Counter for media files uploaded to Tigris.
    public static let totalMediaFilesUploadedToTigris = MetricsService.global.makeCounter(
        name: "total_media_files_uploaded_to_tigris",
        labels: [
            "status": Self.MetricStatus.success.rawValue,
        ]
    )

    /// Counter for failed media file uploads to Tigris.
    public static let totalMediaFilesUploadedToTigrisFailed = MetricsService.global.makeCounter(
        name: "total_media_files_uploaded_to_tigris",
        labels: [
            "status": Self.MetricStatus.fail.rawValue,
        ]
    )

    /// Creates a counter to track Firecrawl markdown scraping metrics.
    /// - Parameters:
    ///   - status: The status of the scraping.
    ///   - url: The URL being scraped.
    /// - Returns: A Prometheus counter for Firecrawl markdown scraping with the given status.
    public static func firecrawlScrapeMarkdown(
        status: Self.MetricStatus,
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

    /// Enum representing the status of a metric.
    public enum MetricStatus: String, Codable {
        /// Indicates that the metric already exists.
        case alreadyExists
        /// Indicates a failure status for the metric.
        case fail
        /// Indicates a start status for the metric.
        case start
        /// Indicates a success status for the metric.
        case success
    }
}
