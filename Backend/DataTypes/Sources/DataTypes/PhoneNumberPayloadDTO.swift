// PhoneNumberPayloadDTO.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public struct PhoneNumberPayloadDTO: Content {
    public var phoneNumber: String

    public init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
}
