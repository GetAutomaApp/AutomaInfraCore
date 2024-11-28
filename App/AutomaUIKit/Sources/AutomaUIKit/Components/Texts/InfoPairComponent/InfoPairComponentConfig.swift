// InfoPairComponentConfig.swift
// was created on 11/28/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

enum InfoPairVariants {
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
