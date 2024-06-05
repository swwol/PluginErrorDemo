import Foundation

struct Config: Decodable {
  struct Output: Decodable {
    let output: String
  }

  struct Info: Decodable {
    enum CodingKeys: String, CodingKey {
      case inputs, outputs
    }

    let inputs: [String]
    let outputs: [Output]

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      if let string = try? container.decode(String.self, forKey: .inputs) {
        inputs = [string]
      } else {
        inputs = try container.decode([String].self, forKey: .inputs)
      }
      if let output = try? container.decode(Output.self, forKey: .outputs) {
        outputs = [output]
      } else {
        outputs = try container.decode([Output].self, forKey: .outputs)
      }
    }
  }

  let input_dir: String?
  let strings: Info?
  let xcassets: Info?
  let colors: Info?
}

extension Config {
  var inputs: [String] {
    [strings, xcassets, colors]
      .compactMap { $0 }
      .flatMap { $0.inputs }
      .map { path in
        [input_dir, path].compactMap { $0 }.joined(separator: "/")
      }
  }

  var outputs: [String] {
    [strings, xcassets, colors]
      .compactMap { $0 }
      .flatMap { $0.outputs }
      .map { $0.output }
  }
}
