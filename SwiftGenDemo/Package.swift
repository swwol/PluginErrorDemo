// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "SwiftGenDemo",
  defaultLocalization: "en",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "SwiftGenDemo",
      targets: ["SwiftGenDemo"]),
  ],
  dependencies: [
    .package(name: "MSPlugins", path: "../MSPlugins"),
  ],
  targets: [
    .target(
      name: "SwiftGenDemo",
      plugins: [
        .plugin(name: "SwiftGenPlugin", package: "MSPlugins"),
      ]
    ),
    .testTarget(name: "SwiftGenDemoTests", dependencies: ["SwiftGenDemo"])
  ]
)
