// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AutomaUIKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "AutomaUIKit",
            targets: ["AutomaUIKit"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "AutomaUIKit",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "AutomaUIKitTests",
            dependencies: ["AutomaUIKit"],
            path: "Tests"
        ),
    ]
)
