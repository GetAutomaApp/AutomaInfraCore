// InfoPairComponentConfig.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

public enum InfoPairVariants: String, CaseIterable {
    case generic
}

/**
 This is the default config for the Info Pair Component
 */
public class InfoPairComponentConfig: ObservableObject {
    @Published public var title: String
    @Published public var description: String
    @Published public var variant: InfoPairVariants

    public init(title: String = "Enter a title here",
                description: String = "Enter a 3 line / 2 line description here",
                variant: InfoPairVariants = .generic)
    {
        self.title = title
        self.description = description
        self.variant = variant
    }
}
