// swift-tools-version:6.1
import PackageDescription

/// The package configuration for the AutomaCLI project.
/// This configuration defines the package name, platforms, dependencies, and targets.
public let package = Package(
    name: "AutomaCLI",
    platforms: [
        .macOS(.v15), // Specifies the minimum macOS version required
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.3"), // Vapor framework dependency
        .package(path: "../Backend/DataTypes"), // Local dependency on DataTypes package
    ],
    targets: [
        .executableTarget(
            name: "AutomaCLI",
            dependencies: [
                .product(name: "Vapor", package: "vapor"), // Dependency on Vapor product
                .product(name: "DataTypes", package: "DataTypes"), // Dependency on DataTypes product
            ],
            swiftSettings: swiftSettings // Swift settings for the target
        ),
        .testTarget(
            name: "CLITests",
            dependencies: [
                .target(name: "AutomaCLI"), // Dependency on AutomaCLI target
            ]
        ),
    ],
    swiftLanguageModes: [.v5] // Specifies the Swift language version
)

/// Provides Swift settings for the package.
/// These settings enable upcoming and experimental features.
private var swiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("DisableOutwardActorInference"), // Enables upcoming feature
        .enableExperimentalFeature("StrictConcurrency"), // Enables experimental feature
    ]
}
