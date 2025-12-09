// TemporalClientExtensions.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Temporal
import Vapor

internal extension TemporalClient {
    static func getServerHostnameFromEnv() throws -> String {
        try Environment.getOrThrow("TEMPORAL_SERVER_HOSTNAME")
    }
}
