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
  ],
  targets: [
    .target(
      name: "AutomaUIKit",
      dependencies: [],
      path: "Sources",
      exclude: [
        "AutomaUIKit/Components/Buttons/IconButtonComponent/IconButtonComponentDocumentation.md",
        "AutomaUIKit/Components/Frames/ButtonFrameComponent/ButtonFrameComponentDocumentation.md"
      ]
    ),
    .testTarget(
      name: "AutomaUIKitTests",
      dependencies: ["AutomaUIKit", "ViewInspector"],
      path: "Tests"
    ),
  ]
)
