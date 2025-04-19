// NoNetworkConnection.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

//
//  NoNetworkConnection.swift
//  AutomaAppShared
//
//  Created by Simon Ferns on 2/23/25.
//
import AutomaUIKit
import SwiftUI

/// View to show when user has no internet connection
public struct NoNetworkConnectionView: View {
    public init() {}

    @StateObject public var titleConfig: InfoPairComponentConfig = .init(
        title: "You're not connected!",
        description: "Please ensure you have an active internet connection!"
    )

    public var body: some View {
        VStack {
            InfoPairComponent(
                config: titleConfig
            )
        }
    }
}
