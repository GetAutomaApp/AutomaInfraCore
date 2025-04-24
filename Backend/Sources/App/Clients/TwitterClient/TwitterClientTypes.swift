// TwitterClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import TwitterAPIKit
import Vapor

/// A protocol defining the base requirements for a Twitter client.
internal protocol TwitterClientBase {
    /// Logger instance for tracking operations.
    var logger: Logger { get }

    /// HTTP client for making requests.
    var client: Client { get }

    /// Database instance for data persistence.
    var database: Database { get }

    /// Twitter API client instance.
    var twitterClient: TwitterAPIClient { get }
}
