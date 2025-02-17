// VerificationCodeInputComponentConfig.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

public enum VerificationCodeInputComponentVariants {
    case generic
}

/// Add a short description here about the config
public class VerificationCodeInputComponentConfig: TextInputComponentComponentConfig {
    public init(
    ) {
        super.init()
        text = " - "
    }
}
