// ReactiveAppState.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaAppShared
import SwiftUI

public class BaseAppEnvironmentObject: ObservableObject {
    @Published public var isLoggedIn: Bool = false
    @Published public var isAccepted: Bool = false
    @Published public var isAppFinishedLoading: Bool = false
    @Published public var isDebugMenuActive: Bool = false
    @Published public var clientVersion: String = "0.0.0"
    @Published public var shouldUpdateApp: Bool = false

    @AppStorage("apiBaseURL") public var apiBaseURL: String = "https://api-sandbox.getautoma.app"

    public init() {}

    public func logout() {
        isLoggedIn = false
        Task {
            await DispatchQueue.main.async {
                KeychainHelper.delete(for: .refreshToken)
            }
        }
    }

    deinit {
        return
    }
}
