import Foundation
import PackagePlugin
#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin
#endif

enum SwiftGenError: Error {
  case configParsingError
}

enum Build {
  case package(PluginContext, Target)
#if canImport(XcodeProjectPlugin)
  case xcode(XcodePluginContext, XcodeTarget)
#endif

  private var searchPaths: [Path] {
    switch self {
    case let .package(context, target):
      return [context.package.directory, target.directory]
#if canImport(XcodeProjectPlugin)
    case let .xcode(context, target):
      return [context.xcodeProject.directory, context.xcodeProject.directory.appending(target.displayName)]
#endif
    }
  }

  var configurationPaths: [Path] {
    searchPaths
      .map { $0.appending("swiftgen.json") }
      .filter { FileManager.default.fileExists(atPath: $0.string) }
  }

  var targetName: String {
    switch self {
    case let .package(_, target):
      return target.name
#if canImport(XcodeProjectPlugin)
    case let .xcode(_, target):
      return target.displayName
#endif
    }
  }

  var targetModuleName: String {
    switch self {
    case let .package(_, target):
      return target.moduleName
#if canImport(XcodeProjectPlugin)
    case .xcode:
      return ""
#endif
    }
  }

  var expectedConfigLocation: String {
    switch self {
    case .package:
      return """
      include a `swiftgen.json` in the target's source directory, or include a shared `swiftgen.json` at the \
      package's root.
      """
#if canImport(XcodeProjectPlugin)
    case .xcode:
      return """
      include a shared `swiftgen.json` at the root of the project directory,  or in a subdirectory with the target name.
      """
#endif
    }
  }
  func hasConfig() -> Bool {
    guard !configurationPaths.isEmpty else {
      Diagnostics.error("""
      No SwiftGen configurations found for target \(targetName). If you would like to generate sources for this \
      target \(expectedConfigLocation)
      """ )
      return false
    }
    return true
  }

  var context: SwiftGenContext {
    switch self {
    case let .package(context, _):
      return context
#if canImport(XcodeProjectPlugin)
    case let .xcode(context, _):
      return context
#endif
    }
  }

  func commands() throws -> [Command] {
    try configurationPaths.map { configuration in
      // decode config file to get required inputs and outputs
      let configJson = try String(contentsOfFile: configuration.string)
      guard let data = configJson.data(using: .utf8) else {
        throw SwiftGenError.configParsingError
      }
      let config = try JSONDecoder().decode(Config.self, from: data)
      let configContainer = configuration.removingLastComponent()
      let inputs = config.inputs.map { configContainer.appending(subpath: $0) }
      let outputs = config.outputs.map { context.pluginWorkDirectory.appending(subpath: $0) }

      Diagnostics.remark("running swiftgen")
      return try Command.swiftgen(using: configuration, build: self)
    }
  }

  private func getLastModifiedDateOfFile(path: Path) -> Date? {
      let fileManager = FileManager.default
      do {
        let attributes = try fileManager.attributesOfItem(atPath: path.string)
          return attributes[.modificationDate] as? Date
      } catch {
          return nil
      }
  }
}

private extension Command {
  static func swiftgen(using configuration: Path?, build: Build) throws -> Command {
    let arguments: [String]
    let environment: [String: any CustomStringConvertible]

    if let configuration {
      arguments = [
        "config",
        "run",
        "--verbose",
        "--config", "\(configuration)",
      ]
      environment = [
        "PROJECT_DIR": build.context.root,
        "TARGET_NAME": build.targetName,
        "PRODUCT_MODULE_NAME": build.targetModuleName,
        "DERIVED_SOURCES_DIR": build.context.pluginWorkDirectory,
      ]
    } else {
      arguments = ["--version"]
      environment = [:]
    }

    return Command.prebuildCommand(
      displayName: "SwiftGen BuildTool Plugin",
      executable: try build.context.tool(named: "swiftgen").path,
      arguments: arguments,
      environment: environment,
      outputFilesDirectory: build.context.pluginWorkDirectory
    )
  }
}
