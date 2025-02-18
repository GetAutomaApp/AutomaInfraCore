// PhoneNumberTextInputComponent.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import PhoneNumberKit
import SwiftUI

struct PhoneNumberTextFieldView: UIViewRepresentable {
    @ObservedObject var config: PhoneNumberTextInputComponentConfig

    private let textField = PhoneNumberTextField()

    func makeUIView(context: Context) -> PhoneNumberTextField {
        textField.withExamplePlaceholder = true
        textField.withFlag = true
        textField.withPrefix = true
        textField.withDefaultPickerUI = true
        textField.placeholder = config.title
        textField.textColor = .init(config.textColor)
        textField.delegate = context.coordinator
        return textField
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(config: config)
    }

    func updateUIView(_ uiView: PhoneNumberTextField, context _: Context) {
        if uiView.text != config.phoneNumber {
            uiView.text = config.phoneNumber
        }
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @ObservedObject var config: PhoneNumberTextInputComponentConfig

        init(config: PhoneNumberTextInputComponentConfig) {
            self.config = config
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            config.phoneNumber = textField.text ?? ""
            if let phoneTextField = textField as? PhoneNumberTextField {
                config.isValid = phoneTextField.isValidNumber
            }
        }
    }
}

public struct PhoneNumberTextInputComponent: View {
    @ObservedObject var config = PhoneNumberTextInputComponentConfig()

    public var body: some View {
        VStack(alignment: .leading) {
            if !config.title.isEmpty {
                Text(config.title)
                    .fontTableFont(config.titleContentFont, config.titleSegmentColor)
            }

            PhoneNumberTextFieldView(config: config)
                .frame(height: 23)
                .padding(config.padding)
                .background(config.currentBackgroundColor)
                .clipShape(RoundedRectangle(cornerSize: config.cornerRadius))

            Text("\(config.errorMessage) ")
                .fontTableFont(
                    config.titleContentFont,
                    config.errorSegmentColor
                )
        }
    }
}
