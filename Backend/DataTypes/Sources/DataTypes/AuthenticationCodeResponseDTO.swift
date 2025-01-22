// AuthenticationCodeResponseDTO.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public struct AuthenticationCodeResponseDTO: Content {
    public let success: Bool
    public let timeout: Double

    public init(success: Bool, timeout: Double) {
        self.success = success
        self.timeout = timeout
    }
}
