// Helpers.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

//
//  Helpers.swift
//  AutomaAppShared
//
//  Created by Simon Ferns on 2/20/25.
//
import SimpleKeychain
import SwiftUI

/// Extension to UIApplication that provides additional functionality for handling keyboard input
public extension UIApplication {
    /// Dismisses the keyboard by resigning the first responder status
    /// This method can be called from anywhere in the app to dismiss the keyboard
    func endEditing() {
        // Sends a resign first responder action through the responder chain
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// A helper class that provides methods for securely storing and retrieving data from the keychain
/// This class is marked with @MainActor to ensure all operations are performed on the main thread
@MainActor
public class KeychainHelper {
    /// Enumeration of available keychain keys for storing different types of tokens
    public enum KeyChainKeys: String {
        /// Key for storing the authentication token
        case authenticationToken
        /// Key for storing the refresh token
        case refreshToken
    }

    /// Static instance of SimpleKeychain configured to only be accessible after first unlock of the device
    public static var keychain = SimpleKeychain(
        accessibility: .afterFirstUnlockThisDeviceOnly
    )

    /// Retrieves a string value from the keychain for the specified key
    /// - Parameter key: The keychain key to retrieve the value for
    /// - Returns: The string value if it exists, nil otherwise
    public static func get(for key: KeyChainKeys) -> String? {
        try? keychain.string(forKey: key.rawValue)
    }

    /// Stores a string value in the keychain for the specified key
    /// - Parameters:
    ///   - key: The keychain key to store the value for
    ///   - value: The string value to store
    /// - Returns: Boolean indicating whether the operation was successful
    @discardableResult
    public static func set(for key: KeyChainKeys, value: String) -> Bool {
        (
            try? keychain.set(value, forKey: key.rawValue)
        ) != nil
    }

    /// Deletes the value associated with the specified key from the keychain
    /// - Parameter key: The keychain key whose value should be deleted
    public static func delete(for key: KeyChainKeys) {
        try? keychain.deleteItem(forKey: key.rawValue)
    }

    deinit {
        return
    }
}
