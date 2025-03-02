// AppLaunchClientConfigDTO.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public struct AppLaunchClientConfigDTO: Content {
    public let requiredClientVersion: String

    public init(currentAppVersion: String = "0.0.0") {
        requiredClientVersion = currentAppVersion
    }
}
