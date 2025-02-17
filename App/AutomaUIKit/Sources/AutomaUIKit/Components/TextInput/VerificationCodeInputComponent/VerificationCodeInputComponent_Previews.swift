// VerificationCodeInputComponent_Previews.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

// Add a preview per state difference (No need to add all states)

struct VerificationCodeInputComponent_Previews: PreviewProvider {
    static var previews: some View {
        VerificationCodeInputComponentWrapperView()
    }
}

struct VerificationCodeInputComponentWrapperView: View {
    @ObservedObject var config = VerificationCodeInputComponentConfig()
    var body: some View {
        VerificationCodeInputComponent(config: config).padding()
    }
}
