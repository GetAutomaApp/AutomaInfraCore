// AccessTokenPayloadDTO.swift
// was created on 12/27/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public struct AccessTokenPayloadDTO: Content {
    public var accessToken: String

    public init(accessToken: String) {
        self.accessToken = accessToken
    }
}
