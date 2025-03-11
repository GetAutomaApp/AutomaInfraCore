// TwitterClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import TwitterAPIKit
import Vapor

protocol TwitterClientBase {
    var logger: Logger { get }
    var client: Client { get }
    var database: Database { get }

    var twitterClient: TwitterAPIClient { get }
}
