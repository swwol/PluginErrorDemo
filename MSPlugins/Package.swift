// swift-tools-version: 5.10
import Foundation
import PackageDescription

let package = Package(
  name: "MSPlugins",
  products: [
    .plugin(name: "SwiftGenPlugin", targets: ["SwiftGenPlugin"]),
    .plugin(name: "SwiftyMockyPlugin", targets: ["SwiftyMockyPlugin"]),
  ],
  targets: [
    .plugin(
      name: "SwiftGenPlugin",
      capability: .buildTool(),
      dependencies: ["swiftgen"]
    ),
    .binaryTarget(
      name: "swiftgen",
      path: "swiftgen.artifactbundle"
    ),
    .plugin(
      name: "SwiftyMockyPlugin",
      capability: .buildTool(),
      dependencies: ["SourceryBinary"],
      exclude: ["README.md"]
    ),
    .binaryTarget(
      name: "SourceryBinary",
      path: "SourceryBinary.artifactbundle"
    )
  ]
)
