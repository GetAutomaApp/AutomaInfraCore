// PrometheusControllerTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

internal struct PrometheusRouteQuery: Content {
    public let authToken: String

    enum CodingKeys: String, CodingKey {
        case authToken = "auth_token"
    }
}
