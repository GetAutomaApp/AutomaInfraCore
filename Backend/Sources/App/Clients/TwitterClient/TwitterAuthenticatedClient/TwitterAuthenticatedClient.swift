// TwitterAuthenticatedClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import TwitterAPIKit
import Vapor

struct TwitterAuthenticatedClient: TwitterClientBase {
    var logger: Logger
    var client: Client
    var database: Database
    var twitterClient: TwitterAPIClient

    public func postTweet(message: String) async throws -> TwitterPostResponse {
        let result = twitterClient.v2.postTweet(
            .init(
                text: message
            )
        )
        let response = await result.responseDecodable(type: TwitterPostResponse.self)
        if let error = response.error {
            logger.error(
                "Error decoding tweet response.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "message": .string(message),
                    "error": .string(error.localizedDescription),
                ]
            )
            throw Abort(.internalServerError)
        }
        guard
            let tweetResponse = response.success
        else {
            logger.error(
                "Failed to post tweet, response nil.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "message": .string(message),
                ]
            )
            throw Abort(.internalServerError)
        }

        return tweetResponse
    }
}
