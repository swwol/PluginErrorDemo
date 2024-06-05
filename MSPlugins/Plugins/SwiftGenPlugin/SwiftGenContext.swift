import PackagePlugin

protocol SwiftGenContext {
  var pluginWorkDirectory: Path { get }
  var root: Path { get }
  func tool(named name: String) throws -> PackagePlugin.PluginContext.Tool
}

extension PluginContext: SwiftGenContext {
  var root: Path {
    package.directory
  }
}
