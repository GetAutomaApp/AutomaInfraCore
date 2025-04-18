// PhoneNumberTextInputComponent.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import PhoneNumberKit
import SwiftUI

internal struct PhoneNumberTextFieldView: UIViewRepresentable {
    @ObservedObject public var config: PhoneNumberTextInputComponentConfig

    private let textField = PhoneNumberTextField()
    public func makeUIView(context: Context) -> PhoneNumberKit.PhoneNumberTextField {
        textField.withExamplePlaceholder = true
        textField.withFlag = true
        textField.withPrefix = true
        textField.withDefaultPickerUI = true
        textField.placeholder = config.title
        textField.textColor = .init(config.textColor)
        textField.delegate = context.coordinator
        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textFieldDidChange(_:)),
            for: .editingChanged
        )
        return textField
    }

    public func updateUIView(
        _ uiView: PhoneNumberKit.PhoneNumberTextField, context _: Context
    ) {
        if uiView.text != config.phoneNumber {
            uiView.text = config.phoneNumber
        }
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @ObservedObject public var config: PhoneNumberTextInputComponentConfig

        init(config: PhoneNumberTextInputComponentConfig) {
            self.config = config
        }

        @objc
        public func textFieldDidChange(_ textField: UITextField) {
            config.phoneNumber = textField.text ?? ""

            if let phoneTextField = textField as? PhoneNumberTextField {
                config.isValid = phoneTextField.isValidNumber
            } else {
                config.isValid = false
            }
        }

        deinit {
            return
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(config: config)
    }
}

public struct PhoneNumberTextInputComponent: View {
    @ObservedObject public var config: PhoneNumberTextInputComponentConfig

    public init(
        config: PhoneNumberTextInputComponentConfig
    ) {
        self.config = config
    }

    public var body: some View {
        VStack(alignment: .leading) {
            if !config.title.isEmpty {
                Text(config.title)
                    .fontTableFont(
                        config.titleContentFont, config.titleSegmentColor
                    )
            }

            PhoneNumberTextFieldView(config: config)
                .frame(height: 23)
                .padding(config.padding)
                .background(config.currentBackgroundColor)
                .clipShape(RoundedRectangle(cornerSize: config.cornerRadius))

            Text("\(config.errorMessage)")
                .fontTableFont(
                    config.titleContentFont,
                    config.errorSegmentColor
                )
        }
    }
}
