import PackagePlugin

protocol SwiftyMockyContext {
  var pluginWorkDirectory: Path { get }
  var root: Path { get }
  func tool(named name: String) throws -> PackagePlugin.PluginContext.Tool
}

extension PluginContext: SwiftyMockyContext {
  var modifiedConfigPath: Path {
    pluginWorkDirectory.appending("swiftyMocky.yml")
  }

  var root: Path {
    package.directory
  }
}

extension SwiftyMockyContext {
  var sourceryCachePath: Path {
    pluginWorkDirectory.appending("sourceryCache")
  }

  var cacheFingerprintPath: Path {
    pluginWorkDirectory.appending("cache-fingerprint")
  }

  var modifiedConfigPath: PackagePlugin.Path {
    pluginWorkDirectory.appending("swiftyMocky.yml")
  }

  var templatePath: Path {
    pluginWorkDirectory.appending("Mock.swifttemplate")
  }
}
