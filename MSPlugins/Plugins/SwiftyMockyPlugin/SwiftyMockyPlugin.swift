import Foundation
import PackagePlugin

@main
struct SwiftyMockyPlugin: BuildToolPlugin {
  enum Error: Swift.Error {
    case configNotFound
  }

  func createBuildCommands(
    context: PluginContext,
    target: Target) throws -> [Command] {
      let inputs = try setup(for: context, configPaths: [context.package.directory, target.directory])
      return [try Command.swiftymocky(context: context, inputs: inputs)]
  }

  func setup(for context: SwiftyMockyContext, configPaths: [Path]) throws -> [Path] {
    let fileManager = FileManager.default

    let configPath = configPaths
      .map { $0.appending("swiftyMocky.yml") }
      .first(where: { fileManager.fileExists(atPath: $0.string) })

    // check there is a swiftyMocky.yml at directory root
    guard let configPath else {
      Diagnostics.warning("Build plugin didn't run because swiftyMocky.yml not found")
      throw Error.configNotFound
    }

    let fingerprint = try makeCacheFingerprint(context: context)

    if try !fingerprintMatchesStored(fingerprint: fingerprint, context: context) {
      Diagnostics.remark("cache fingerprint does not match - deleting sourcery cache folder and SwiftTemplate folder")
      try fileManager.forceClean(path: context.sourceryCachePath)
      try fileManager.forceClean(path: context.pluginWorkDirectory.appending("SwiftTemplate"), replaceWithEmpty: false)
      try fingerprint.write(to: context.cacheFingerprintPath.url, atomically: true, encoding: .utf8)
    }

    // write template to work directory
    try Self.template.write(to: context.templatePath.url,
                            atomically: true,
                            encoding: .utf8)
    // read and transform the config file
    let config = try readAndTransformConfigFile(context: context, configPath: configPath)
    // save the modified config
    try config.write(to: context.modifiedConfigPath.url,
                     atomically: true,
                     encoding: .utf8)
    // extract paths of input files
    return try inputPaths(from: config, configPath: configPath)
  }

  func readAndTransformConfigFile(context: SwiftyMockyContext, configPath: Path) throws -> String {
    let configFromFile = try String(contentsOfFile: configPath.string)

    // replace instances of - ./ with package directory
    let updatedConfig = configFromFile
      .replacingOccurrences(of: "- ./", with: "- " + context.root.string + "/")
      .trimmingCharacters(in: .whitespacesAndNewlines)

       // create template and outputs section
       let templateAndOutputSections =
     """
     templates:
       - \(context.templatePath.string)
     output:
         \(context.pluginWorkDirectory.appending("Mock.generated.swift").string)
     """

       let transformed = updatedConfig + "\n" + templateAndOutputSections
       return transformed
  }

  func inputPaths(from config: String, configPath: Path) throws -> [Path] {
    let lines = config.split(whereSeparator: \.isNewline)

    guard let sources = lines.firstIndex(where: { $0.contains("sources:") }) else {
      Diagnostics.error("unableToFindSourcesStart")
      return []
    }
    let sourcesSection = lines[sources + 1..<lines.count]
    guard let include = sourcesSection.firstIndex(where: { $0.contains("include:") }) else {
      Diagnostics.error("unable to find included files")
      return []
    }

    let includeSection = sourcesSection[include + 1..<sourcesSection.count]
      .map {
        String($0)
          .trimmingCharacters(in: .whitespacesAndNewlines)
      }
    let endOfIncludeSection = includeSection.firstIndex(where: { !$0.hasPrefix("-") })
    let justThePaths = includeSection.prefix(upTo: endOfIncludeSection ?? includeSection.count).map { $0.dropFirst(2) }
    let sourcePaths = justThePaths.map { Path(String($0)) }

    // collect Paths
    var filePaths = [Path]()

    let fileManager = FileManager.default
    for path in sourcePaths {
      if path.extension == nil {
        // this is a directory
        let url = URL(fileURLWithPath: path.string)
        guard let enumerator = fileManager.enumerator(at: url,
                                                      includingPropertiesForKeys: [.isRegularFileKey],
                                                      options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
          continue
        }

        for case let fileURL as URL in enumerator {
          let fileAttributes = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
          if fileAttributes.isRegularFile! && fileURL.pathExtension == "swift" {
            filePaths.append(Path(String(fileURL.absoluteString.dropFirst("file://".count))))
          }
        }
      } else {
        // this is a file
        if path.extension == "swift" {
          filePaths.append(path)
        }
      }
    }
    return filePaths + [configPath]
  }

  private func fingerprintMatchesStored(fingerprint: String, context: SwiftyMockyContext) throws -> Bool {
    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: context.cacheFingerprintPath.string) else {
      return false
    }

    let stored = try String(contentsOfFile: context.cacheFingerprintPath.string)
    return stored == fingerprint
  }

  private func makeCacheFingerprint(context: SwiftyMockyContext) throws -> String {
    let xcodeVersion = shell("xcodebuild -version")
    let sourceryVersion = shell("\(try context.tool(named: "sourcery").path) --version")
    return xcodeVersion.appending(sourceryVersion)
  }

  private func shell(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.standardInput = nil
    task.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    return output
  }
}

extension Command {
  static func swiftymocky(context: SwiftyMockyContext, inputs: [Path]) throws -> Command {
    .buildCommand(
      displayName: "SwiftyMocky BuildTool Plugin",
      executable: try context.tool(named: "sourcery").path,
      arguments: [
        "--config", context.modifiedConfigPath.string,
        "--cacheBasePath", context.sourceryCachePath.string,
        "--buildPath", context.pluginWorkDirectory.string,
      ],
      environment: [:],
      inputFiles: inputs,
      outputFiles: [context.pluginWorkDirectory.appending("Mock.generated.swift")]
    )
  }
}

private extension Path {
  var url: URL {
    URL(string: "file://" + string)!
  }
}

private extension FileManager {
  /// Re-create the given directory
  func forceClean(path: Path, replaceWithEmpty: Bool = true) throws {
    if fileExists(atPath: path.string) {
      try removeItem(atPath: path.string)
    }
    if replaceWithEmpty {
      try createDirectory(atPath: path.string, withIntermediateDirectories: false)
    }
  }
}
