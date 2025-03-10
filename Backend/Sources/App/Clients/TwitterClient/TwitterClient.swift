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

    func requestToken() {}
}
