// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Backend",
    platforms: [
        .macOS(.v15),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.3"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🐘 Fluent driver for Postgres.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(path: "./DataTypes"),
        .package(url: "https://github.com/awslabs/aws-sdk-swift.git", from: "1.0.66"),
        .package(url: "https://github.com/vapor/jwt.git", from: "5.0.0"),
        .package(url: "https://github.com/MacPaw/OpenAI.git", branch: "main"),
        .package(url: "https://github.com/soto-project/soto.git", from: "7.3.0"),
        .package(url: "https://github.com/swift-server/swift-prometheus.git", from: "2.0.0"),
        .package(url: "https://github.com/m-barthelemy/vapor-queues-fluent-driver.git", from: "3.0.0-beta1"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "DataTypes", package: "DataTypes"),
                .product(name: "AWSSNS", package: "aws-sdk-swift"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "OpenAI", package: "OpenAI"),
                .product(name: "SotoS3", package: "soto"),
                .product(name: "SotoSNS", package: "soto"),
                .product(name: "Prometheus", package: "swift-prometheus"),
                .product(name: "QueuesFluentDriver", package: "vapor-queues-fluent-driver"),
            ],
            exclude: [
                "Documentation.md",
            ],
            swiftSettings: swiftSettings,
            linkerSettings: [
                .linkedLibrary("crypto", .when(platforms: [.linux])),
                .linkedLibrary("icudata", .when(platforms: [.linux])),
                .linkedLibrary("icuuc", .when(platforms: [.linux])),
                .linkedLibrary("ssl", .when(platforms: [.linux])),
                .linkedLibrary("z", .when(platforms: [.linux])),
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        ),
    ],
    swiftLanguageModes: [.v5]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("StrictConcurrency"),
] }
