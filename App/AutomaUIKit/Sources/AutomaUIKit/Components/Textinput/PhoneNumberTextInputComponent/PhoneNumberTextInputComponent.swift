// PhoneNumberTextInputComponent.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import PhoneNumberKit
import SwiftUI

struct PhoneNumberTextFieldView: UIViewRepresentable {
    private let textField = PhoneNumberTextField()
    @Binding var phoneNumber: String
    @Binding var isValid: Bool

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
        Coordinator(
            phoneNumber: $phoneNumber,
            isValid: updateIsValid
        )
    }

    func updateUIView(_ uiView: PhoneNumberTextField, context _: Context) {
        if uiView.text != phoneNumber {
            uiView.text = phoneNumber
        }
    }

    func updateIsValid() {
        isValid = textField.isValidNumber
        print("is valid \(phoneNumber) \(textField.isValidNumber)")
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var phoneNumber: String
        let isValid: () -> Void

        init(phoneNumber: Binding<String>, isValid: @escaping () -> Void) {
            _phoneNumber = phoneNumber
            self.isValid = isValid
        }

        func textFieldDidChangeSelection(
            _ textField: UITextField
        ) {
            print("phoneNumber")
            phoneNumber = textField.text ?? ""
            isValid()
        }
    }
}

public struct PhoneNumberTextInputComponent: View {
    @ObservedObject var config: PhoneNumberTextInputComponentConfig = .init()
    @State private var phoneField: PhoneNumberTextFieldView?

    public var body: some View {
        VStack {
            phoneField
                .frame(height: 23)
                .padding(config.padding)
                .background(
                    config.currentBackgroundColor
                )
                .clipShape(
                    RoundedRectangle(
                        cornerSize: config.cornerRadius
                    )
                )

            TextInputComponentComponent(config: config)

            Text("Phone Num \(config.phoneNumber)")
                .fontTableFont(FontTable.SFPro.Body.body1, .white)

            Text("Is Valid \(config.isValid)")
                .fontTableFont(FontTable.SFPro.Body.body1, .white)
        }
        .onAppear {
            phoneField = PhoneNumberTextFieldView(
                phoneNumber: $config.phoneNumber,
                isValid: $config.isValid
            )
        }
    }
}
