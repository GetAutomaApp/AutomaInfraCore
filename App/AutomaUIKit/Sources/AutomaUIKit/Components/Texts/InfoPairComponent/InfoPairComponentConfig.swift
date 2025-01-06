// InfoPairComponentConfig.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

enum InfoPairVariants: String, CaseIterable {
    case generic
}

/**
 This is the default config for the Info Pair Component
 */
class InfoPairComponentConfig: ObservableObject {
    @Published var title: String = "Enter a title here"
    @Published var description: String = "Enter a 3 line / 2 line description here"
    @Published var variant: InfoPairVariants = .generic
}
