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
        .package(url: "https://github.com/nalexn/ViewInspector", from: "0.9.0"),
    ],
    targets: [
        .target(
            name: "AutomaAppShared",
            dependencies: [],
            path: "Sources"
        ),
    ]
)
