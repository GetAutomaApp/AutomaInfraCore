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
    ///
    /// This method sends a tweet to Twitter using the authenticated API client.
    /// It logs the operation and handles any errors that occur during the request.
    ///
    /// - Parameter message: The text content of the tweet to post.
    /// - Returns: A `TwitterPostResponse` containing the posted tweet details.
    /// - Throws: `TwitterAuthenticatedClientError` if the request fails or returns invalid data.
    public func postTweet(message: String) async throws -> Self.TwitterPostResponse {
        // Start the backend metric for posting a tweet
        BackendMetric.twitterPostTweet(status: .start).increment()

        // Send the tweet using the Twitter API client
        let result = twitterClient.v2.postTweet(
            .init(
                text: message
            )
        )
        // Await the response and decode it into a TwitterPostResponse
        let response = await result.responseDecodable(type: Self.TwitterPostResponse.self)

        // Check for errors in the response
        if let error = response.error {
            // Log and throw an error if the response contains an error
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

        // Ensure the response contains the tweet details
        guard let tweetResponse = response.success else {
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

        // Increment the success metric
        BackendMetric.twitterPostTweet(status: .success).increment()

        // Return the successful tweet response
        return tweetResponse
    }

    /// A structure representing the response from a Twitter post request.
    ///
    /// This struct contains the data returned by Twitter after a tweet is posted,
    /// encapsulated in a `TwitterPostResponseData` object.
    public struct TwitterPostResponse: Content {
        /// The data returned by Twitter, including the tweet's text and ID.
        public let data: Self.TwitterPostResponseData
    }

    /// A structure representing the data of a Twitter post response.
    ///
    /// This struct contains the text and ID of the tweet that was posted.
    public struct TwitterPostResponseData: Content {
        /// The text content of the posted tweet.
        public let text: String

        /// The unique identifier of the posted tweet.
        public let id: String
    }
}
