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
        .package(url: "https://github.com/auth0/SimpleKeychain.git", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "AutomaAppShared",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                "AutomaUIKit",
                .product(name: "DataTypes", package: "DataTypes"),
                .product(name: "SimpleKeychain", package: "SimpleKeychain"),
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
