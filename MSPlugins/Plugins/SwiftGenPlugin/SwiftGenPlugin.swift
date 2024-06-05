import Foundation
import PackagePlugin

@main
struct SwiftGenPlugin: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
    try createBuildCommands(for: .package(context, target))
  }

  func createBuildCommands(for build: Build) throws -> [Command] {
    // Validate paths list
    guard build.hasConfig() else {
      return []
    }
    return try build.commands()
  }
}

extension Target {
  /// Try to access the underlying `moduleName` property
  /// Falls back to target's name
  var moduleName: String {
    switch self {
    case let target as SourceModuleTarget:
      return target.moduleName
    default:
      return ""
    }
  }
}
