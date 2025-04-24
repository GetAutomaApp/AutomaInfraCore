// BaseAppEnvironmentObject.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaAppShared
import SwiftUI

/// A base environment object that manages the global application state.
/// This class provides reactive state management for core app functionality including
/// authentication status, app loading state, and configuration settings.
public class BaseAppEnvironmentObject: ObservableObject {
    /// Indicates whether a user is currently logged into the application
    @Published public var isLoggedIn: Bool = false

    /// Indicates whether the user has accepted the necessary terms and conditions
    @Published public var isAccepted: Bool = false

    /// Indicates whether the application has completed its initial loading sequence
    @Published public var isAppFinishedLoading: Bool = false

    /// Controls the visibility of the debug menu in the application
    @Published public var isDebugMenuActive: Bool = false

    /// The current version of the client application
    @Published public var clientVersion: String = "0.0.0"

    /// Indicates whether the application requires an update
    @Published public var shouldUpdateApp: Bool = false

    /// The base URL for API requests, persisted using AppStorage
    /// Defaults to the sandbox environment
    @AppStorage("apiBaseURL")
    public var apiBaseURL: String = "https://api-sandbox.getautoma.app"

    /// Initializes a new instance of the BaseAppEnvironmentObject
    public init() {
        Never
    }

    /// Logs out the current user and clears their refresh token from the keychain
    /// This method:
    /// - Sets isLoggedIn to false
    /// - Asynchronously removes the refresh token from the keychain
    public func logout() {
        isLoggedIn = false
        Task {
            await DispatchQueue.main.async {
                KeychainHelper.delete(for: .refreshToken)
            }
        }
    }

    /// Cleanup method called when the object is being deallocated
    deinit {
        return
    }
}
