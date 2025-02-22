// DebugMenu.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

//
//  DebugMenu.swift
//  AutomaAppShared
//
//  Created by Simon Ferns on 12/16/24.
//
import AutomaUIKit
import SwiftUI

public struct DebugMenu: View {
    @EnvironmentObject var baseEnvironmentConfig: BaseAppEnvironmentObject
    @StateObject var closeButtonConfig: IconButtonComponentConfig = .init()

    public init() {}

    public var body: some View {
        Form {
            Section {
                HStack {
                    Text("Debug Menu")
                        .fontTableFont(
                            FontTable.Crimson.Headings.head5,
                            DesignTokens.colors.primaryText
                        )
                    Spacer()
                    IconButtonComponent(
                        config: closeButtonConfig,
                        onSelfAppear: { config in
                            config.icon = .x
                            config.defaultPadding = DesignTokens.padding.minimal
                            config.isCircular = true
                            config.fillSpace = false
                        },
                        action: {
                            baseEnvironmentConfig.isDebugMenuActive = false
                        }
                    )
                }
            }
            Section(header: Text("Profile Actions")) {
                Text("🍃 Log Out")
            }.onTapGesture {
                baseEnvironmentConfig.logout()
                baseEnvironmentConfig.isDebugMenuActive = false
            }
        }
        Spacer()
    }
}

#Preview {
    DebugMenu()
        .preferredColorScheme(.dark)
}
