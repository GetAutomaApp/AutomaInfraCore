// AnyOrientationStackComponentConfig.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

public enum AnyOrientationStackComponentVariants {
    case hstack, vstack, zstack
}

/// Add a short description here about the config
public class AnyOrientationStackComponentConfig: ObservableObject {
    @Published var variant: AnyOrientationStackComponentVariants = .vstack

    @Published var vstackAlignment: HorizontalAlignment
    @Published var hstackAlignment: VerticalAlignment
    @Published var spacing: CGFloat

    public init(
        variant: AnyOrientationStackComponentVariants = .vstack,
        vstackAlignment: HorizontalAlignment = .leading,
        hstackAlignment: VerticalAlignment = .bottom,
        spacing: CGFloat = 0
    ) {
        self.variant = variant
        self.vstackAlignment = vstackAlignment
        self.hstackAlignment = hstackAlignment
        self.spacing = spacing
    }
}
