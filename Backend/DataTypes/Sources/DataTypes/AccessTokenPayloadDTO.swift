// AccessTokenPayloadDTO.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public struct AccessTokenPayloadDTO: Content {
    public var accessToken: String

    public init(accessToken: String) {
        self.accessToken = accessToken
    }
}
