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
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0")),
        .package(path: "../AutomaUIKit"),
        .package(path: "../../Backend/DataTypes"),
    ],
    targets: [
        .target(
            name: "AutomaAppShared",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                "AutomaUIKit",
                .product(name: "DataTypes", package: "DataTypes"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "AutomaAppSharedTests",
            dependencies: ["AutomaAppShared"],
            path: "Tests"
        ),
    ]
)
