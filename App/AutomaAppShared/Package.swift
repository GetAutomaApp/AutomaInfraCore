// swift-tools-version: 6.0

import PackageDescription

/// AutomaAppShared Package Definition
/// This package contains shared components and utilities for the Automa iOS and macOS applications.
///
/// The package includes:
/// - Network communication utilities using Alamofire
/// - UI components from AutomaUIKit
/// - Data models from DataTypes
/// - Secure storage functionality using SimpleKeychain
public let package = Package(
    // Name of the Swift package
    name: "AutomaAppShared",

    // Supported platforms and their minimum versions
    platforms: [
        .iOS(.v17), // Requires iOS 17.0 or later
        .macOS(.v15), // Requires macOS 15.0 or later
    ],

    // Products defined by the package
    products: [
        // Main library product that clients can depend on
        .library(
            name: "AutomaAppShared",
            targets: ["AutomaAppShared"]
        ),
    ],

    // External package dependencies
    dependencies: [
        // ViewInspector for SwiftUI testing and inspection
        .package(url: "https://github.com/nalexn/ViewInspector", from: "0.9.0"),

        // Alamofire for networking
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0")),

        // Local package dependencies
        .package(path: "../AutomaUIKit"),
        .package(path: "../../Backend/DataTypes"),

        // SimpleKeychain for secure storage
        .package(url: "https://github.com/auth0/SimpleKeychain.git", from: "1.2.0"),
    ],

    // Package targets
    targets: [
        // Main target containing the package's source code
        .target(
            name: "AutomaAppShared",
            dependencies: [
                // Network communication framework
                .product(name: "Alamofire", package: "Alamofire"),

                // UI components and utilities
                "AutomaUIKit",

                // Data model definitions
                .product(name: "DataTypes", package: "DataTypes"),

                // Secure keychain storage
                .product(name: "SimpleKeychain", package: "SimpleKeychain"),
            ],
            path: "Sources"
        ),

        // Test target for unit tests
        .testTarget(
            name: "AutomaAppSharedTests",
            dependencies: ["AutomaAppShared"],
            path: "Tests"
        ),
    ]
)
