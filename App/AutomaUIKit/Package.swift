// swift-tools-version: 6.0

import PackageDescription

/// AutomaUIKit Package Definition
/// This package contains UI components and utilities for the Automa application.
/// The package is compatible with iOS 17+ and macOS 15+.
///
/// Package structure:
/// - Main target: AutomaUIKit - Contains all UI components and utilities
/// - Test target: AutomaUIKitTests - Contains unit tests for the components
///
/// Dependencies:
/// - ViewInspector: For UI testing and inspection
/// - ViewExtractor: Custom view extraction utility
/// - PhoneNumberKit: Phone number formatting and validation
public let package = Package(
    name: "AutomaUIKit",
    platforms: [
        .iOS(.v17), // Requires iOS 17 or later
        .macOS(.v15), // Requires macOS 15 or later
    ],
    products: [
        // Main library product
        .library(
            name: "AutomaUIKit",
            targets: ["AutomaUIKit"]
        ),
    ],
    dependencies: [
        // External package dependencies
        .package(url: "https://github.com/nalexn/ViewInspector", from: "0.9.0"),
        .package(url: "https://github.com/GetAutomaApp/ViewExtractor", from: "1.0.0"),
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "4.0.2"),
        // .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "3.7.0"),
    ],
    targets: [
        // Main target configuration
        .target(
            name: "AutomaUIKit",
            dependencies: ["ViewExtractor", "PhoneNumberKit"],
            path: "Sources",
            resources: [
                .process("Assets/Fonts"), // Add this to process the font files from the Assets folder
                // Processed documentation resources
                .process(
                    "AutomaUIKit/Components/TextInput/VerificationCodeInputComponent/VerificationCodeInputComponentDocumentation.md"
                ),
                .process(
                    "AutomaUIKit/Components/TextInput/PhoneNumberTextInputComponent/PhoneNumberTextInputComponentDocumentation.md"
                ),
                .process(
                    "AutomaUIKit/Components/Frames/TextInputFrameComponent/TextInputFrameComponentDocumentation.md"
                ),
            ]
        ),
        // Test target configuration
        .testTarget(
            name: "AutomaUIKitTests",
            dependencies: ["AutomaUIKit", "ViewInspector"],
            path: "Tests"
        ),
    ]
)
