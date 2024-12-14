// Initialisation.swift
// was created on 12/5/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation
import SwiftUI

#if canImport(AppKit)
    import AppKit
#endif

public extension View {
    func isMacOS() -> Bool {
        #if os(iOS)
            return false
        #else
            return true
        #endif
    }

    func getRect() -> CGRect {
        #if os(iOS)
            return UIScreen.main.bounds
        #endif

        #if canImport(AppKit)
            return NSScreen.main!.visibleFrame
        #endif
    }
}
