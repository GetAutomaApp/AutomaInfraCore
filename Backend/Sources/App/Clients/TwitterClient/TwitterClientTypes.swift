// TwitterClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import TwitterAPIKit
import Vapor

protocol TwitterClientBase {
    public var logger: Logger { get }
    public var client: Client { get }
    public var database: Database { get }
    public var twitterClient: TwitterAPIClient { get }
}
