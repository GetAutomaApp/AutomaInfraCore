// generate.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

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

struct AddToFileType {
    let name: String
    let configurations: [AddToFileConfig]
}

struct AddToFileConfig {
    let template: String
    let addToFile: String
}

let basePath = "../../generators/"
let baseAppPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .deletingLastPathComponent()
    .appendingPathComponent("App")
    .standardized.path + "/"
let baseDataTypesPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .deletingLastPathComponent()
    .appendingPathComponent("Backend/DataTypes")
    .standardized.path + "/"
let baseBackendAppPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .deletingLastPathComponent()
    .appendingPathComponent("Backend/Sources/App")
    .standardized.path + "/"

let fileTypes: [FileType] = [
    FileType(name: "ui-component", configurations: [
        FileConfig(
            fromDirectory: "ui-component/",
            toDirectory: "\(baseAppPath)AutomaUIKit/Sources/AutomaUIKit/Components/",
            nestToDirectory: "__CAPNAME__Component/",
            templates: [
                "__CAPNAME__Component.swift.template",
                "__CAPNAME__Component_Previews.swift.template",
                "__CAPNAME__ComponentConfig.swift.template",
            ]
        ),
    ]),
    FileType(name: "ui-modifier", configurations: [
        FileConfig(
            fromDirectory: "ui-modifier/",
            toDirectory: "\(baseAppPath)AutomaUIKit/Sources/AutomaUIKit/Core/Modifiers/",
            nestToDirectory: "__CAPNAME__Modifier/",
            templates: [
                "__CAPNAME__Modifier.swift.template",
                "__CAPNAME__Modifier_Previews.swift.template",
            ]
        ),
    ]),
    FileType(
        name: "backend-controller",
        configurations: [
            FileConfig(
                fromDirectory: "backend-controller/",
                toDirectory: "Sources/App/Controllers/",
                nestToDirectory: "__CAPNAME__Controller/",
                templates: [
                    "__CAPNAME__Controller.swift.template",
                ]
            ),
            FileConfig(
                fromDirectory: "controller-interactor/",
                toDirectory: "\(baseAppPath)AutomaAppShared/Sources/AutomaAppShared/Interactors/",
                nestToDirectory: "",
                templates: [
                    "__CAPNAME__ControllerInteractor.swift.template",
                ]
            ),
        ]
    ),
    FileType(
        name: "model",
        configurations: [
            FileConfig(
                fromDirectory: "model/",
                toDirectory: "\(baseBackendAppPath)Models/",
                nestToDirectory: "",
                templates: [
                    "__CAPNAME__Model.swift.template",
                ]
            ),
            FileConfig(
                fromDirectory: "model/",
                toDirectory: "\(baseDataTypesPath)Sources/DataTypes/",
                nestToDirectory: "",
                templates: [
                    "__CAPNAME__DTO.swift.template",
                ]
            ),
            FileConfig(
                fromDirectory: "migration/",
                toDirectory: "\(baseBackendAppPath)Migrations/",
                nestToDirectory: "",
                templates: [
                    "__CAPNAME__Migration__TIMESTAMP__.swift.template",
                ]
            ),
        ]
    ),
    FileType(
        name: "dto",
        configurations: [
            FileConfig(
                fromDirectory: "dto/",
                toDirectory: "\(baseDataTypesPath)Sources/DataTypes/",
                nestToDirectory: "",
                templates: [
                    "__CAPNAME__DTO.swift.template",
                ]
            ),
        ]
    ),
    FileType(
        name: "migration",
        configurations: [
            FileConfig(
                fromDirectory: "migration/",
                toDirectory: "./Sources/App/Migrations/",
                nestToDirectory: "",
                templates: [
                    "__CAPNAME__Migration__TIMESTAMP__.swift.template",
                ]
            ),
        ]
    ),
    FileType(
        name: "backend-service",
        configurations: [
            FileConfig(
                fromDirectory: "backend-service/",
                toDirectory: "\(baseBackendAppPath)Services/",
                nestToDirectory: "__CAPNAME__Service/",
                templates: [
                    "__CAPNAME__Service.swift.template",
                ]
            ),
        ]
    ),
    FileType(
        name: "backend-interactor",
        configurations: [
            FileConfig(
                fromDirectory: "controller-interactor/",
                toDirectory: "\(baseAppPath)AutomaAppShared/Sources/AutomaAppShared/Interactors/",
                nestToDirectory: "",
                templates: [
                    "__CAPNAME__ControllerInteractor.swift.template",
                ]
            ),
        ]
    ),
    FileType(
        name: "async-job",
        configurations: [
            FileConfig(
                fromDirectory: "backend-async-job/",
                toDirectory: "Sources/App/Procs/Jobs/",
                nestToDirectory: "__CAPNAME__AsyncJob/",
                templates: [
                    "__CAPNAME__AsyncJob.swift.template",
                ]
            ),
        ]
    ),
    FileType(
        name: "command",
        configurations: [
            FileConfig(
                fromDirectory: "command/",
                toDirectory: "Sources/App/Commands/",
                nestToDirectory: "",
                templates: [
                    "__CAPNAME_LOWER__.swift.template",
                ]
            ),
        ]
    ),
    FileType(
        name: "screen",
        configurations: [
            FileConfig(
                fromDirectory: "screen/",
                toDirectory: "\(baseAppPath)AutomaAppShared/Sources/AutomaAppShared/Screens/",
                nestToDirectory: "",
                templates: [
                    "__CAPNAME__Screen.swift.template",
                ]
            ),
        ]
    ),
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

        @Option(
            name: "nestedDir",
            help: "The directory you want to nest the component into (added to the default path)."
        )
        var nestedDir: String?

        @Flag(name: "copy", help: "Copy files to the destination directory.")
        var copy: Bool
    }

    func run(using _: CommandContext, signature: Signature) throws {
        let componentName = signature.filename
        let copy = signature.copy
        var output = ""

        print("🚀 Current Working Directory: \(FileManager.default.currentDirectoryPath)")

        for fileType in fileTypes {
            guard fileType.name == signature.component else { continue }

            for fileConfig in fileType.configurations {
                let fromDirectory = URL(fileURLWithPath: "\(basePath)\(fileConfig.fromDirectory)").standardized.path
                let toDirectory = URL(fileURLWithPath: fileConfig.toDirectory).standardized.path
                let nestedDir = signature.nestedDir ?? ""

                let toNestedDir = URL(fileURLWithPath: "\(toDirectory)\(arrayToPascalCase([nestedDir]))/")
                    .standardized.path

                let nestToDirectory = rename(text: fileConfig.nestToDirectory, componentName: componentName)
                let destinationPath = URL(fileURLWithPath: "\(toNestedDir)/\(nestToDirectory)").standardized.path

                print("🛠️  Resolving Paths:")
                print("- From Directory: \(fromDirectory)")
                print("- To Directory: \(toDirectory)")
                print("- To Nested Directory: \(toNestedDir)")
                print("- Final Destination Path: \(destinationPath)")

                if FileManager.default.fileExists(atPath: nestToDirectory) {
                    throw Abort(.badRequest, reason: "Component directory '\(nestToDirectory)' already exists.")
                }

                try FileManager.default.createDirectory(
                    atPath: destinationPath,
                    withIntermediateDirectories: true,
                    attributes: nil
                )

                for template in fileConfig.templates {
                    let sourceFile = URL(fileURLWithPath: "\(fromDirectory)/\(template)").standardized.path
                    let fileNameFormatted = rename(text: template, componentName: componentName)
                        .replacingOccurrences(of: ".template", with: "")

                    let destinationFile = URL(fileURLWithPath: "\(destinationPath)/\(fileNameFormatted)")
                        .standardized.path

                    if FileManager.default.fileExists(atPath: destinationFile), !copy {
                        throw Abort(
                            .badRequest,
                            reason: "Component implementation '\(destinationFile)' already exists."
                        )
                    }

                    output += try moveAndRenameFile(
                        source: sourceFile,
                        destination: destinationFile,
                        componentName: componentName,
                        shouldWrite: !copy
                    )
                }

                print("✅ Successfully created a \(fileType.name) called '\(componentName)' in '\(toNestedDir)'.")
            }
        }

        if copy {
            Shell().run("echo '\(output)' | pbcopy")
        }
    }

    func moveAndRenameFile(source: String, destination: String, componentName: String,
                           shouldWrite: Bool = true) throws -> String
    {
        let absoluteSourcePath = URL(fileURLWithPath: source).standardized.path
        print("Absolute Source Path: \(absoluteSourcePath)")

        let absoluteDestinationPath = URL(fileURLWithPath: destination).standardized.path
        print("Absolute Destination Path: \(absoluteDestinationPath)")

        // Ensure the parent directory exists before writing the file
        let destinationDirectory = (absoluteDestinationPath as NSString).deletingLastPathComponent
        if !FileManager.default.fileExists(atPath: destinationDirectory) {
            try FileManager.default.createDirectory(
                atPath: destinationDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        // Check if the source file exists before trying to read it
        guard FileManager.default.fileExists(atPath: absoluteSourcePath) else {
            throw Abort(.notFound, reason: "Template file not found: \(absoluteSourcePath)")
        }

        // Read the file content
        var content = try String(contentsOfFile: absoluteSourcePath, encoding: .utf8)

        // Rename occurrences of __CAPNAME__ in the content
        content = rename(text: content, componentName: componentName)

        // Write the content to the new file
        if shouldWrite {
            print("Writing \(absoluteDestinationPath)")
            try content.write(toFile: absoluteDestinationPath, atomically: true, encoding: .utf8)
        }

        return "\(destination)\n\(content)"
    }

    func rename(text: String, componentName: String) -> String {
        let words = pascalToWordsArray(componentName)
        return text
            // Replace all occurrences of __CAPNAME__ with with the correct format helloComponent -> HelloComponent
            .replacingOccurrences(of: "__CAPNAME__", with: componentName)
            // Replace all occurrences of __CAPNAME_LOWER__ with with the correct format helloComponent ->
            // hellocomponent
            .replacingOccurrences(of: "__CAPNAME_LOWER__", with: componentName.lowercased())
            // Replace all occurrences of __CAPNAME_DASHED__ with with the correct format helloComponent ->
            // hello-component
            .replacingOccurrences(of: "__CAPNAME_DASHED__", with: arrayToDashed(words))
            // Replace all occurrences of __CAPNAME_DASHEDUPPER__ with with the correct format helloComponent ->
            // Hello-Component
            .replacingOccurrences(of: "__CAPNAME_DASHEDUPPER__", with: arrayToDashed(words, capitalized: true))
            // Replace all occurrences of __CAPNAME_HASKELL__ with with the correct format helloComponent ->
            // helloComponent
            .replacingOccurrences(of: "__CAPNAME_HASKELL__", with: arrayToHaskell(words))
            // Replace all occurrences of __CAPNAME_SPACING__ with with the correct format helloComponent -> hello
            // Component
            .replacingOccurrences(of: "__CAPNAME_SPACING__", with: arrayToSpaceDelimited(words))
            // Replaces all occurences of __TIMESTAMP__ with the current timestamp
            // __TIMESTAMP__ -> 173847283
            .replacingOccurrences(of: "__TIMESTAMP__", with: "\(Int(Date().timeIntervalSince1970))")
    }

    func pascalToWordsArray(_ pascal: String) -> [String] {
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
            return []
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
