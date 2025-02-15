// PhoneNumberTextInputComponent.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import PhoneNumberKit
import SwiftUI

struct PhoneNumberTextFieldView: UIViewRepresentable {
    @Binding var phoneNumber: String
    @Binding var isValid: Bool

    private let textField = PhoneNumberTextField()

    func makeUIView(context: Context) -> PhoneNumberTextField {
        textField.withExamplePlaceholder = true
        textField.withFlag = true
        textField.withPrefix = true
        textField.withDefaultPickerUI = true
        textField.placeholder = "Enter phone number"
        textField.textColor = UIColor(DesignTokens.colors.primaryText)
        textField.delegate = context.coordinator
        return textField
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(phoneNumber: $phoneNumber, isValid: $isValid)
    }

    func updateUIView(_ uiView: PhoneNumberTextField, context _: Context) {
        if uiView.text != phoneNumber {
            uiView.text = phoneNumber
        }
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var phoneNumber: String
        @Binding var isValid: Bool

        init(phoneNumber: Binding<String>, isValid: Binding<Bool>) {
            _phoneNumber = phoneNumber
            _isValid = isValid
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            phoneNumber = textField.text ?? ""
            if let phoneTextField = textField as? PhoneNumberTextField {
                isValid = phoneTextField.isValidNumber
            }
        }
    }
}

public struct PhoneNumberTextInputComponent: View {
    @ObservedObject var config = PhoneNumberTextInputComponentConfig()

    public var body: some View {
        VStack {
            PhoneNumberTextFieldView(
                phoneNumber: $config.phoneNumber,
                isValid: $config.isValid
            )
            .frame(height: 23)
            .padding(config.padding)
            .background(config.currentBackgroundColor)
            .clipShape(RoundedRectangle(cornerSize: config.cornerRadius))

            TextInputComponentComponent(config: config)

            Text("Phone Num \(config.phoneNumber)")
                .fontTableFont(FontTable.SFPro.Body.body1, .white)

            Text("Is Valid \(config.isValid)")
                .fontTableFont(FontTable.SFPro.Body.body1, .white)
        }
    }
}
