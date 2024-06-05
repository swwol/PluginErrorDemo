#if canImport(XcodeProjectPlugin)
import PackagePlugin
import XcodeProjectPlugin

extension SwiftGenPlugin: XcodeBuildToolPlugin {
  func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
    try createBuildCommands(for: .xcode(context, target))
  }
}

extension XcodePluginContext: SwiftGenContext {
  var root: PackagePlugin.Path {
    xcodeProject.directory
  }
}
#endif
