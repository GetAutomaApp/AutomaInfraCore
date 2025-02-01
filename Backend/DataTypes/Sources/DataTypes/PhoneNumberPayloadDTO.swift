// PhoneNumberPayloadDTO.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import PhoneNumberKit
import Vapor

public struct PhoneNumberPayloadDTO: Content {
    public var phoneNumber: String

    public init(phoneNumber: String) throws {
        let phoneNumberKit = PhoneNumberKit()
        do {
            let phoneNumberParsed = try phoneNumberKit.parse(phoneNumber)
            self.phoneNumber = phoneNumberKit
                .format(phoneNumberParsed, toType: .e164)
        } catch {
            throw GenericErrors.invalidPhoneNumber
        }
    }
}
