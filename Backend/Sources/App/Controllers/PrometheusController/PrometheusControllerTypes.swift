// PrometheusControllerTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

struct PrometheusRouteQuery: Content {
    let authToken: String

    enum CodingKeys: String, CodingKey {
        case authToken = "auth_token"
    }
}
