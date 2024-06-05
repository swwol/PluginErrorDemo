#if canImport(XcodeProjectPlugin)
import Foundation
import PackagePlugin
import XcodeProjectPlugin

extension SwiftyMockyPlugin: XcodeBuildToolPlugin {
  // Xcode project entry point
  func createBuildCommands(
    context: XcodePluginContext,
    target: XcodeTarget) throws -> [Command] {
      let inputs = try setup(
        for: context,
        configPaths: [
          context.xcodeProject.directory,
          context.xcodeProject.directory.appending(target.displayName),
        ]
      )
      return [try Command.swiftymocky(context: context, inputs: inputs)]
  }
}

extension XcodePluginContext: SwiftyMockyContext {
  var root: PackagePlugin.Path {
    xcodeProject.directory
  }
}

#endif
