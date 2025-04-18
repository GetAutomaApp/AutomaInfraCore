// VerificationCodeInputComponentConfig.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

public enum VerificationCodeInputComponentVariants {
    case generic
}

public class VerificationCodeInputComponentConfig: TextInputComponentComponentConfig {
    @Published public var separatorIcon: DesignIcons

    public init(
        separatorIcon: DesignIcons = .subtraction
    ) {
        self.separatorIcon = separatorIcon
        super.init()
        text = " - "
    }

    deinit {}
}
