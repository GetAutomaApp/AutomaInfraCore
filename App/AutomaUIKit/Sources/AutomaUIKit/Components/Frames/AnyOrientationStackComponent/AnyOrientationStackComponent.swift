// AnyOrientationStackComponent.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI
import ViewExtractor

/**
 The `AnyOrientationStackComponent` is a reusable component that ___

 Add a detailed description here of how to use this

 - Parameters:
     - config: The Config Used to manage state & modifications to  `AnyOrientationStackComponent`
 - Returns: some View

 To see usage examples & visuals, check out `AnyOrientationStackModifierDocumentation.md`
 */
public struct AnyOrientationStackComponent<Content: View>: View {
    @ObservedObject var config: AnyOrientationStackComponentConfig
    @ViewBuilder let content: Content

    public init(config: AnyOrientationStackComponentConfig, @ViewBuilder content: () -> Content) {
        self.config = config
        self.content = content()
    }

    public var body: some View {
        Extract(content) { views in
            switch config.variant {
            case .vstack:
                VStack(alignment: config.vstackAlignment, spacing: config.spacing) {
                    ForEach(views) { view in
                        view
                    }
                }
            case .hstack:
                HStack(alignment: config.hstackAlignment, spacing: config.spacing) {
                    ForEach(views) { view in
                        view
                    }
                }
            case .zstack:
                ZStack {
                    ForEach(views) { view in
                        view
                    }
                }
            }
        }
    }
}
