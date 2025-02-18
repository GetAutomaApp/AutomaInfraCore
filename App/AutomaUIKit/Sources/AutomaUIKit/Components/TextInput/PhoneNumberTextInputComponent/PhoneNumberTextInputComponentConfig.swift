// PhoneNumberTextInputComponentConfig.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

public enum PhoneNumberTextInputComponentVariants {}

/// Add a short description here about the config
public class PhoneNumberTextInputComponentConfig: TextInputComponentComponentConfig {
    @Published public var phoneNumber: String

    public var timesUntilShowErrorMessage = 7

    @Published public var isValid: Bool {
        didSet {
            if timesUntilShowErrorMessage > 0 {
                timesUntilShowErrorMessage -= 1
                return
            }

            if !isValid {
                errorMessage = "Invalid Phone Number"
                return
            }

            errorMessage = ""
        }
    }

    init(phoneNumber: String = "+1", isValid: Bool = false) {
        self.phoneNumber = phoneNumber
        self.isValid = isValid

        super.init(
            title: "Phone Number"
        )
    }
}
