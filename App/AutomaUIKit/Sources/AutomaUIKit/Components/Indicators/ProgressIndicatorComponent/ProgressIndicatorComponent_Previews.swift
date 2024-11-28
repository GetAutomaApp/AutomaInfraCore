// ProgressIndicatorComponent_Previews.swift
// was created on 11/28/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

// Add a preview per state difference (No need to add all states)

struct ProgressIndicatorComponent_Previews: PreviewProvider {
    static var previews: some View {
        TestProgressView()
    }
}

struct TestProgressView: View {
    @ObservedObject var config = ProgressIndicatorComponentConfig()

    var body: some View {
        VStack {
            ProgressIndicatorComponent(config: config)

            Button("+") {
                config.incrementStep(3)
            }

            Button("-") {
                config.decrementStep(3)
            }

            Text("\(config.currentStep)")

            Button("Reset") {
                config.setStep(1)
            }
        }
    }
}
