// AuthPhoneCodePayloadDTO.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public struct AuthPhoneCodePayloadDTO: Content {
    public let phoneNumber: String
    public let code: String

    // TODO: Add validators

    public init(phoneNumber: String, code: String) {
        self.phoneNumber = phoneNumber
        self.code = code
    }
}
