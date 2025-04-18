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

internal enum BaseEnvironmentUrl: String, CaseIterable {
    case localhost = "http://localhost:8080"
    case production = "https://api-production.getautoma.app"
    case sandbox = "https://api-sandbox.getautoma.app"
    case staging = "https://api-staging.getautoma.app"
}

/// Debug menu for application, to change app behavior, environment and other configuration options
public struct DebugMenu: View {
    @EnvironmentObject public var baseEnvironmentConfig: BaseAppEnvironmentObject

    @StateObject public var closeButtonConfig: IconButtonComponentConfig = .init()

    @StateObject public var environmentPickerConfig: TextInputFrameComponentConfig = .init(
        text: BaseEnvironmentUrl.sandbox.rawValue
    )

    @StateObject public var environmentPicketButtonConfig: TextButtonComponentConfig = .init()

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
                            config.icon = .other
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

            Section(header: Text("Api Configuration")) {
                VStack {
                    Picker(
                        "API URL",
                        selection: $environmentPickerConfig.text
                    ) {
                        ForEach(
                            BaseEnvironmentUrl.allCases,
                            id: \.rawValue
                        ) { url in
                            Text(url.rawValue)
                        }
                    }

                    TextInputFrameComponent(
                        config: environmentPickerConfig
                    ) {
                        environmentPickerConfig.text = baseEnvironmentConfig.apiBaseURL
                    }

                    TextButtonComponent(
                        config: environmentPicketButtonConfig,
                        onSelfAppear: { config in
                            config.text = "Set URL"
                        },
                        action: { _ in
                            let url = URL(string: environmentPickerConfig.text)

                            if let url {
                                baseEnvironmentConfig.apiBaseURL = url.absoluteString
                                baseEnvironmentConfig.logout()
                                baseEnvironmentConfig.isDebugMenuActive = false
                            } else {
                                print(
                                    "HANDLE ERRORS INVALID URL \(environmentPickerConfig.text)"
                                )
                            }
                        }
                    )
                }
            }
        }
        Spacer()
    }
}

#Preview {
    DebugMenu()
        .preferredColorScheme(.dark)
}
