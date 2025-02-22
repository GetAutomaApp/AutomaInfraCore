// IOSApp.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaAppShared
import SwiftUI

@main
struct IOSApp: App {
    @StateObject var baseConfig = BaseAppEnvironmentObject()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .onTapGesture(count: 5, perform: {
                    #if DEBUG
                        baseConfig.isDebugMenuActive = true
                    #endif
                })
                .task {
                    let loop = AuthenticationLoop(
                        baseURL: baseConfig.apiBaseURL
                    )
                    baseConfig.isLoggedIn = await loop.getAccessToken()

                    baseConfig.isAppFinishedLoading = true

                    Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                        print("Looping")
                        Task {
                            let result = await loop.getAccessToken()
                            await MainActor.run {
                                baseConfig.isLoggedIn = result
                            }
                        }
                    }
                }.fullScreenCover(isPresented: $baseConfig.isDebugMenuActive, content: {
                    DebugMenu()
                })
                .environmentObject(baseConfig)
        }
    }
}
