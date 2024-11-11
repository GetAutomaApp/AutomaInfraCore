// generate.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp. All rights reserved.

import Vapor

struct FileType {
  let name: String
  let configurations: [FileConfig]
}

struct FileConfig {
  let fromDirectory: String
  let toDirectory: String
  let nestToDirectory: String
  let templates: [String]
}

let fileTypes: [FileType] = [
  FileType(name: "ui-component", configurations: [
    FileConfig(
      fromDirectory: "./generators/ui-component/",
      toDirectory: "../App/AutomaUIKit/Sources/AutomaUIKit/Components/",
      nestToDirectory: "__CAPNAME__Component/",
      templates: [
        "__CAPNAME__Component.swift.template",
        "__CAPNAME__Component_Previews.swift.template",
        "__CAPNAME__ComponentConfig.swift.template",
        "__CAPNAME__ComponentDocumentation.md.template",
      ]
    ),
    FileConfig(
      fromDirectory: "./generators/ui-component-testing/",
      toDirectory: "../App/AutomaUIKit/Tests/Components/",
      nestToDirectory: "__CAPNAME__ComponentTests/",
      templates: [
        "__CAPNAME__ComponentTests.swift.template",
      ]
    ),
  ]),
]

struct GenerateAppComponent: Command {
  var help: String {
    "Generates an app component based on the given name."
  }

  struct Signature: CommandSignature {
    @Argument(
      name: "name",
      help: "The component to generate. They can be: \(fileTypes.map(\.name).joined(separator: ", "))"
    )
    var component: String

    @Argument(name: "filename", help: "The name of the component to generate.")
    var filename: String

    @Argument(
      name: "nestedDir",
      help: "The directory you want to nest the component into (added to the default path)."
    )
    var nestedDir: String
  }

  func run(using _: CommandContext, signature: Signature) throws {
    let componentName = signature.filename

    for fileType in fileTypes {
      guard fileType.name == signature.component else { continue }

      for fileConfig in fileType.configurations {
        let fromDirectory = fileConfig.fromDirectory
        let toDirectory = fileConfig.toDirectory
        let nestedDir = signature.nestedDir
        let toNestedDir = "\(toDirectory)\(arrayToPascalCase([nestedDir]))/"
          .replacingOccurrences(of: "//", with: "/")
        let nestToDirectory = rename(text: fileConfig.nestToDirectory, componentName: componentName)
        let destinationPath = "\(toNestedDir)\(nestToDirectory)".replacingOccurrences(of: "//", with: "/")

        if FileManager.default.fileExists(atPath: nestToDirectory) {
          throw Abort(.badRequest, reason: "Component directory '\(nestToDirectory)' already exists.")
        }

        try FileManager.default.createDirectory(
          atPath: destinationPath,
          withIntermediateDirectories: true,
          attributes: nil
        )

        for template in fileConfig.templates {
          let sourceFile = "\(fromDirectory)\(template)"
          let fileNameFormatted = rename(text: template, componentName: componentName).replacingOccurrences(
            of: ".template",
            with: ""
          )
          let destinationFile =
            "\(destinationPath)\(fileNameFormatted)"

          if FileManager.default.fileExists(atPath: destinationFile) {
            throw Abort(
              .badRequest,
              reason: "Component implementation '\(destinationFile)' already exists."
            )
          }

          try moveAndRenameFile(
            source: sourceFile,
            destination: destinationFile,
            componentName: componentName
          )
        }

        print("Successfully created a \(fileType.name) called '\(componentName)' in '\(toNestedDir)'.")
      }
    }
  }

  func moveAndRenameFile(source: String, destination: String, componentName: String) throws {
    // Check if the source file exists before trying to read it
    guard FileManager.default.fileExists(atPath: source) else {
      throw Abort(.notFound, reason: "Template file not found: \(source)")
    }

    // Read the file content
    var content = try String(contentsOfFile: source)

    // Rename occurrences of __CAPNAME__ in the content
    content = rename(text: content, componentName: componentName)

    // Write the content to the new file
    try content.write(toFile: destination, atomically: true, encoding: .utf8)
  }

  func rename(text: String, componentName: String) -> String {
    let words = pascalToWordsArray(componentName)
    return text
      .replacingOccurrences(of: "__CAPNAME__", with: componentName)
      .replacingOccurrences(of: "__CAPNAME_LOWER__", with: componentName.lowercased())
      .replacingOccurrences(of: "__CAPNAME_DASHED__", with: arrayToDashed(words))
      .replacingOccurrences(of: "__CAPNAME_DASHEDUPPER__", with: arrayToDashed(words, capitalized: true))
      .replacingOccurrences(of: "__CAPNAME_HASKELL__", with: arrayToHaskell(words))
      .replacingOccurrences(of: "__CAPNAME_SPACING__", with: arrayToSpaceDelimited(words))
  }

  func pascalToWordsArray(_ pascal: String) -> [String]? {
    let pattern = "([A-Z])"

    do {
      let regex = try NSRegularExpression(pattern: pattern, options: [])
      let range = NSRange(location: 0, length: pascal.utf16.count)
      let modifiedString = regex.stringByReplacingMatches(
        in: pascal,
        options: [],
        range: range,
        withTemplate: " $1"
      )

      return modifiedString.trimmingCharacters(in: .whitespaces).components(separatedBy: " ")
    } catch {
      // Handle the error (e.g., print it, return nil, or handle in another way)
      print("Invalid regular expression: \(error)")
      return nil
    }
  }

  func arrayToDashed(_ array: [String], capitalized: Bool = false) -> String {
    let dashedString = array.joined(separator: "-")

    if capitalized, let firstCharacter = dashedString.first {
      let capitalizedString = "\(firstCharacter.uppercased())\(dashedString.dropFirst())"
      return capitalizedString
    }

    return dashedString
  }

  func arrayToHaskell(_ array: [String]) -> String {
    guard !array.isEmpty else { return "" }

    return array.enumerated().map { index, element in
      if index == 0 {
        element.lowercased()
      } else {
        element.lowercased().capitalized
      }
    }.joined(separator: "")
  }

  func arrayToSpaceDelimited(_ array: [String]) -> String {
    array.joined(separator: " ")
  }

  func arrayToPascalCase(_ array: [String]) -> String {
    array.enumerated().map(\.element.capitalized).joined()
  }
}
