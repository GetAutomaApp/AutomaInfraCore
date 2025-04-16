// TwitterAuthenticatedClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import TwitterAPIKit
import Vapor

/// A client for making authenticated requests to the Twitter API.
/// This client handles posting tweets and other authenticated operations
/// using a valid Twitter API access token.
internal struct TwitterAuthenticatedClient: TwitterClientBase {
    /// Logger instance for tracking operations
    public let logger: Logger

    /// HTTP client for making requests
    public let client: Client

    /// Database instance for data persistence
    public let database: Database

    /// Twitter API client instance configured with authentication
    public let twitterClient: TwitterAPIClient

    /// Posts a new tweet to Twitter with the given message.
    /// - Parameter message: The text content of the tweet to post
    /// - Returns: A TwitterPostResponse containing the posted tweet details
    /// - Throws: TwitterAuthenticatedClientError if the request fails or returns invalid data
    public func postTweet(message: String) async throws -> TwitterPostResponse {
        BackendMetric.twitterPostTweet(status: .start).increment()

        let result = twitterClient.v2.postTweet(
            .init(
                text: message
            )
        )
        let response = await result.responseDecodable(type: TwitterPostResponse.self)
        if let error = response.error {
            BackendMetric.twitterPostTweet(status: .fail).increment()
            logger.error(
                "Error decoding tweet response.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "message": .string(message),
                    "error": .string(String(reflecting: error)),
                ]
            )
            throw TwitterAuthenticatedClientError.responseError(error)
        }
        guard
            let tweetResponse = response.success
        else {
            BackendMetric.twitterPostTweet(status: .fail).increment()
            logger.error(
                "Failed to post tweet, response nil.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "message": .string(message),
                ]
            )
            throw TwitterAuthenticatedClientError.responseEmpty
        }

        BackendMetric.twitterPostTweet(status: .success).increment()

        return tweetResponse
    }
}
