// IOSApp.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaAppShared
import SwiftUI

@main
struct IOSApp: App {
    @StateObject var baseConfig = BaseAppEnvironmentObject()
    @StateObject var networkChecker: NetworkManager = .init()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .onTapGesture(count: 5) {
                    #if DEBUG
                        baseConfig.isDebugMenuActive = true
                    #endif
                }
                .task {
                    let launchManager = AppLaunch(
                        baseURL: baseConfig.apiBaseURL
                    )

                    if networkChecker.isConnected {
                        let serverRequiredVersion = await launchManager.getClientConfig()

                        if serverRequiredVersion.requiredClientVersion > baseConfig.clientVersion {
                            baseConfig.shouldUpdateApp = true
                        }

                        baseConfig.isLoggedIn = await launchManager.getAccessToken()
                        if baseConfig.isLoggedIn {
                            baseConfig.isAccepted = await launchManager
                                .isUserAccepted()
                        }
                    }

                    baseConfig.isAppFinishedLoading = true

                    Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { _ in
                        Task {
                            if await networkChecker.isConnected {
                                let result = await launchManager.getAccessToken()
                                await MainActor.run {
                                    baseConfig.isLoggedIn = result
                                }
                            }
                        }
                    }
                }.fullScreenCover(isPresented: $baseConfig.isDebugMenuActive) {
                    DebugMenu()
                }
                .environmentObject(baseConfig)
                .environmentObject(networkChecker)
        }
    }
}
