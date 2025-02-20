// AuthenticationFormScreenFrame.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaUIKit
import SwiftUI

public struct AuthenticationFormScreenFrame<CenterContent: View>: View {
    public var title: String = "Enter Title"
    public var description: String = "Enter Desc"

    @StateObject public var titleConfig: InfoPairComponentConfig = .init()
    @StateObject public var buttonConfig: IconButtonComponentConfig = .init()

    @Binding public var isValid: Bool

    @ViewBuilder let centerContent: () -> CenterContent

    let action: () async -> Void

    public var body: some View {
        VStack(alignment: .leading) {
            InfoPairComponent(config: titleConfig, onSelfAppear: { config in
                config.title = title
                config.description = description
            })

            Spacer()

            centerContent()

            Spacer()

            IconButtonComponent(config: buttonConfig, onSelfAppear: { config in
                print("calling on appear now")
                config.isDisabled = true
                config.icon = .arrowRight
            }, action: {
                await action()
            })
            .onChange(of: isValid) {
                buttonConfig.isDisabled = !isValid
            }
        }
        .defaultScreenPadding()
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}
