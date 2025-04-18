// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "AutomaCLI",
    platforms: [
        .macOS(.v15),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.3"),
        .package(path: "../Backend/DataTypes"),
    ],
    targets: [
        .executableTarget(
            name: "AutomaCLI",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "DataTypes", package: "DataTypes"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "CLITests",
            dependencies: [.target(name: "AutomaCLI")]
        ),
    ],
    swiftLanguageModes: [.v5]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("StrictConcurrency"),
] }
