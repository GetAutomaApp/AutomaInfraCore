// VerificationCodeInputComponent.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

public enum FocusedField {
    case input1
    case input2
}

public struct VerificationCodeInputComponent: View {
    @ObservedObject var config: VerificationCodeInputComponentConfig
    @FocusState var focusedText: FocusedField?

    let onSelfAppear: (VerificationCodeInputComponentConfig) -> Void

    public init(
        config: VerificationCodeInputComponentConfig,
        focusedText: FocusedField? = nil,
        onSelfAppear: @escaping (VerificationCodeInputComponentConfig) -> Void = { _ in }
    ) {
        self.config = config
        self.onSelfAppear = onSelfAppear
        self.focusedText = focusedText
    }

    private func createTextBinding(index: Int) -> Binding<String> {
        .init(get: {
            let splits = config.text.split(separator: "-", omittingEmptySubsequences: false).map { $0
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .symbols)
                .trimmingCharacters(in: .illegalCharacters)
            }

            return splits.count >= index + 1 ? splits[index] : ""
        }, set: { new in
            var splits = config.text.split(separator: "-", omittingEmptySubsequences: false).map { $0
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .symbols)
                .trimmingCharacters(in: .illegalCharacters)
            }

            let newCleaned = new
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .symbols)
                .trimmingCharacters(in: .illegalCharacters)
                .replacingOccurrences(of: "-", with: "")

            splits[index] = newCleaned
            config.text = splits.joined(separator: "-")
        })
    }

    public var body: some View {
        VStack(alignment: .leading) {
            if !config.title.isEmpty {
                Text(config.title)
                    .fontTableFont(config.titleContentFont, config.titleSegmentColor)
            }

            HStack {
                TextField(config.ghostText, text: createTextBinding(index: 0))
                    .focused($focusedText, equals: .input1)
                    .onSubmit {
                        if focusedText == .input1 {
                            focusedText = .input2
                        }
                    }
                    .disabled(config.isDisabled)
                    .padding(config.padding)
                    .background(
                        config.currentBackgroundColor
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerSize: config.cornerRadius
                        )
                    )
                    .textCase(.lowercase)

                config.separatorIcon.image

                TextField(config.ghostText, text: createTextBinding(index: 1))
                    .focused($focusedText, equals: .input2)
                    .onSubmit {
                        if focusedText == .input1 {
                            focusedText = .input2
                        }
                    }
                    .disabled(config.isDisabled)
                    .padding(config.padding)
                    .background(
                        config.currentBackgroundColor
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerSize: config.cornerRadius
                        )
                    )
                    .textCase(.lowercase)

            }.onAppear {
                onSelfAppear(config)
            }

            Text("\(config.errorMessage) ")
                .fontTableFont(
                    config.titleContentFont,
                    config.errorSegmentColor
                )
        }
    }
}
