// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AutomaAppShared",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "AutomaAppShared",
            targets: ["AutomaAppShared"]
        ),
    ],
    dependencies: [
        .package(path: "../AutomaUIKit"),
    ],
    targets: [
        .target(
            name: "AutomaAppShared",
            dependencies: ["AutomaUIKit"],
            path: "Sources"
        ),
    ]
)
