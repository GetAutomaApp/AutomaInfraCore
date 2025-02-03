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

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        try self.init(phoneNumber: phoneNumber)
    }
}
