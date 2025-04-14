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

public extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

@MainActor
public class KeychainHelper {
    public enum KeyChainKeys: String {
        case authenticationToken, refreshToken
    }

    static var keychain = SimpleKeychain(
        accessibility: .afterFirstUnlockThisDeviceOnly
    )

    public static func get(for key: KeyChainKeys) -> String? {
        try? keychain.string(forKey: key.rawValue)
    }

    public static func set(for key: KeyChainKeys, value: String) -> Bool {
        (
            try? keychain.set(value, forKey: key.rawValue)
        ) != nil
    }

    public static func delete(for key: KeyChainKeys) {
        try? keychain.deleteItem(forKey: key.rawValue)
    }
}
