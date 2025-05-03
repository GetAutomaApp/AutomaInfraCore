// PrometheusControllerTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

/// Represents the query parameters for Prometheus routes.
internal struct PrometheusRouteQuery: Content {
    /// The authentication token for accessing Prometheus metrics.
    public let authToken: String

    /// Coding keys to map the JSON keys to the struct properties.
    public enum CodingKeys: String, CodingKey {
        case authToken = "auth_token"
    }
}
