// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "PluginIssue",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "PluginIssue",
      targets: ["PluginIssue"]),
    .library(
      name: "PluginIssueMocks",
      targets: ["PluginIssueMocks"]),
  ],
  dependencies: [
    .package(name: "MSPlugins", path: "../MSPlugins"),
    .package(url: "https://github.com/MakeAWishFoundation/SwiftyMocky", exact: "4.1.0"),
  ],
  targets: [
    .target(
      name: "PluginIssue"
    ),
    .target(
      name: "PluginIssueMocks",
      dependencies: [
        "PluginIssue",
        "SwiftyMocky"
      ],
      plugins: [
        .plugin(name: "SwiftyMockyPlugin", package: "MSPlugins"),
      ]
    ),
    .testTarget(
      name: "PluginIssueTests",
      dependencies: [
        "PluginIssue",
        "PluginIssueMocks"
      ]
    ),
   ]
)
