// TwitterClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation
import Vapor

struct TwitterClient {
    let logger: Logger
    let client: Client

    private let TWITTER_API_APP_KEY: String
    private let TWITTER_API_APP_SECRET_KEY: String

    init(logger: Logger, client: Client) throws {
        self.logger = logger
        self.client = client
        TWITTER_API_APP_KEY = try Environment.getOrThrow("TWITTER_API_APP_KEY")
        TWITTER_API_APP_SECRET_KEY = try Environment.getOrThrow("TWITTER_API_APP_SECRET_KEY")
    }

    func requestToken() async throws {
        let response = try await client.post("https://api.x.com/oauth/request_token") { request in
            request.headers.add(
                name: "Authorization",
                value: "OAuth oauth_consumer_key=\"tbet3F32lFbIuotP4EnNE2Hct\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1741277191\",oauth_nonce=\"ERc1ftQDpx5\",oauth_version=\"1.0\",oauth_callback=\"http%3A%2F%2F127.0.0.1%3A8080%2FTwitter%2Fredirect\",oauth_signature=\"DgqzH9x%2BkPl%2BjCYBE69ztntw6bQ%3D\""
            )
        }

        var request = URLRequest(
            url: URL(string: "https://api.x.com/oauth/request_token")!,
            timeoutInterval: Double.infinity
        )
        request.addValue(
            "OAuth oauth_consumer_key=\"tbet3F32lFbIuotP4EnNE2Hct\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"1741277191\",oauth_nonce=\"ERc1ftQDpx5\",oauth_version=\"1.0\",oauth_callback=\"http%3A%2F%2F127.0.0.1%3A8080%2FTwitter%2Fredirect\",oauth_signature=\"DgqzH9x%2BkPl%2BjCYBE69ztntw6bQ%3D\"",
            forHTTPHeaderField: "Authorization"
        )

        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data else {
                print(String(describing: error))
                return
            }
            print(String(data: data, encoding: .utf8)!)
        }

        task.resume()
    }
}
