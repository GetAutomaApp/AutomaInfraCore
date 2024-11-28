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
    @State private var currentCount: Int = 1

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            ProgressIndicatorComponent(
                totalSteps: 4,
                currentStep: $currentCount
            )

            Button("+") {
                currentCount += 1
            }

            Button("-") {
                currentCount -= 1
            }

            Text("Current Count: \(currentCount)")
        }
        .onReceive(timer) { _ in
            // If you want automatic increment
            if currentCount < 4 {
                currentCount += 1
            } else {
                currentCount = 1
            }
        }
    }
}
