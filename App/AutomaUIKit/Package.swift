// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AutomaUIKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "AutomaUIKit",
            targets: ["AutomaUIKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/nalexn/ViewInspector", from: "0.9.0"),
        .package(url: "https://github.com/GetAutomaApp/ViewExtractor", from: "1.0.0"),
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "4.0.2"),
        // .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "3.7.0"),
    ],
    targets: [
        .target(
            name: "AutomaUIKit",
            dependencies: ["ViewExtractor", "PhoneNumberKit"],
            path: "Sources",
            exclude: [
                "AutomaUIKit/Components/Texts/InfoPairComponent/InfoPairComponentDocumentation.md",
                "AutomaUIKit/Components/Indicators/ProgressIndicatorComponent/ProgressIndicatorComponentDocumentation.md",
            ],
            resources: [
                .process("Assets/Fonts"), // Add this to process the font files from the Assets folder
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
        .testTarget(
            name: "AutomaUIKitTests",
            dependencies: ["AutomaUIKit", "ViewInspector"],
            path: "Tests"
        ),
    ]
)
