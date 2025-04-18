// ForceUpdate.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaUIKit
import StoreKit
import SwiftUI

public struct ForceUpdate: View {
    public init() {}

    @StateObject public var titleConfig: InfoPairComponentConfig = .init(
        title: "It's time for an update!",
        description: "You have an older version of the app!"
    )

    @StateObject public var buttonConfig: TextButtonComponentConfig = .init()

    public var body: some View {
        VStack(alignment: .leading) {
            InfoPairComponent(config: titleConfig)
            Spacer()
            TextButtonComponent(config: buttonConfig) { config in
                config.text = "Update Now"
            } action: { _ in
                openUpdateScreen()
            }
        }.defaultScreenPadding()
    }

    public func openUpdateScreen() {
        if let url = URL(string: "https://apps.apple.com/us/app/places-curated-discovery/id6446208302") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    ForceUpdate()
        .preferredColorScheme(.dark)
}
