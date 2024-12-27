// AuthPhoneCodePayloadDTO.swift
// was created on 12/27/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public struct AuthPhoneCodePayloadDTO: Content {
    public let phoneNumber: String
    public let code: String

    // TODO: Add validators
}
