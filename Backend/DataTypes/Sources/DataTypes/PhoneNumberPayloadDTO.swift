// PhoneNumberPayloadDTO.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import PhoneNumberKit
import Vapor

public struct PhoneNumberPayloadDTO: Content {
    public let phoneNumber: String

    public init(number: String) throws {
        let phoneNumberUtility = PhoneNumberUtility()

        do {
            let phoneNumberParsed = try phoneNumberUtility.parse(number)
            phoneNumber = phoneNumberUtility.format(phoneNumberParsed, toType: .e164)
        } catch {
            throw GenericErrors.invalidPhoneNumber
        }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        try self.init(number: phoneNumber)
    }
}
