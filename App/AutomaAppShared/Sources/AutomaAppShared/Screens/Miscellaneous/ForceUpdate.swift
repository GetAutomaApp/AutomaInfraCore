// ForceUpdate.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaUIKit
import SwiftUI

public struct ForceUpdate: View {
    public init() {}

    @StateObject var titleConfig: InfoPairComponentConfig = .init(
        title: "It's time for an update!",
        description: "You have an older version of the app!"
    )

    @StateObject var buttonConfig: TextButtonComponentConfig = .init()

    public var body: some View {
        VStack(alignment: .leading) {
            InfoPairComponent(config: titleConfig)
            Spacer()
            TextButtonComponent(config: buttonConfig) { config in
                config.text = "Update Now"
            }
        }.defaultScreenPadding()
    }
}

#Preview {
    ForceUpdate()
        .preferredColorScheme(.dark)
}
