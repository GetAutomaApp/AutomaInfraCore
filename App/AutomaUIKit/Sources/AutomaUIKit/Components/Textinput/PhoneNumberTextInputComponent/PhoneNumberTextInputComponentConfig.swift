// PhoneNumberTextInputComponentConfig.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

public enum PhoneNumberTextInputComponentVariants {}

/// Add a short description here about the config
public class PhoneNumberTextInputComponentConfig: TextInputComponentComponentConfig {
    @Published public var phoneNumber: String = "+1"
    @Published public var isValid: Bool = false
}
