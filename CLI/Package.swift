// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "AutomaCLI",
    platforms: [
        .macOS(.v15),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.3"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(path: "../Backend/DataTypes"),
    ],
    targets: [
        .executableTarget(
            name: "AutomaCLI",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "DataTypes", package: "DataTypes"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "CLITests",
            dependencies: [
                .target(name: "AutomaCLI"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("StrictConcurrency"),
] }
