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
    FileType(name: "ui-modifier", configurations: [
        FileConfig(
            fromDirectory: "./generators/ui-modifier/",
            toDirectory: "../App/AutomaUIKit/Sources/AutomaUIKit/Core/Modifiers/",
            nestToDirectory: "__CAPNAME__Modifier/",
            templates: [
                "__CAPNAME__Modifier.swift.template",
                "__CAPNAME__ModifierDocumentation.md.template",
                "__CAPNAME__Modifier_Previews.swift.template",
            ]
        ),
        FileConfig(
            fromDirectory: "./generators/ui-modifier-testing/",
            toDirectory: "../App/AutomaUIKit/Tests/Modifiers/",
            nestToDirectory: "__CAPNAME__ModifierTests/",
            templates: [
                "__CAPNAME__ModifierTests.swift.template",
            ]
        ),
    ]),
    FileType(
        name: "backend-controller",
        configurations: [
            FileConfig(
                fromDirectory: "./generators/backend-controller/",
                toDirectory: "Sources/App/Controllers/",
                nestToDirectory: "__CAPNAME__Controller/",
                templates: [
                    "__CAPNAME__Controller.swift.template",
                ]
            ),
            FileConfig(
                fromDirectory: "./generators/backend-controller/",
                toDirectory: "Tests/AppTests/Controllers/",
                nestToDirectory: "__CAPNAME__ControllerTests/",
                templates: [
                    "__CAPNAME__ControllerIntegrationTests.swift.template",
                    "__CAPNAME__ControllerUnitTests.swift.template",
                ]
            ),
            FileConfig(
                fromDirectory: "./generators/controller-interactor/",
                toDirectory: "../App/AutomaAppShared/Sources/AutomaAppShared/Interactors/",
                nestToDirectory: "",
                templates: [
                    "__CAPNAME__ControllerInteractor.swift.template",
                ]
            ),
            FileConfig(
                fromDirectory: "./generators/controller-interactor/",
                toDirectory: "../App/AutomaAppShared/Tests/ControllerInteractors/",
                nestToDirectory: "__CAPNAME__ControllerTests/",
                templates: [
                    "__CAPNAME__ControllerInteractorUnitTests.swift.template",
                    "__CAPNAME__ControllerInteractorIntegrationTests.swift.template",
                ]
            ),
        ]
    ),
    FileType(
        name: "model",
        configurations: [
            FileConfig(
                fromDirectory: "./generators/model/",
                toDirectory: "./Sources/App/Models/",
                nestToDirectory: "",
                templates: [
                    "__CAPNAME__Model.swift.template",
                ]
            ),
            FileConfig(
                fromDirectory: "./generators/model/",
                toDirectory: "./DataTypes/Sources/DataTypes/",
                nestToDirectory: "",
                templates: [
                    "__CAPNAME__DTO.swift.template",
                ]
            ),
            FileConfig(
                fromDirectory: "./generators/migration/",
                toDirectory: "./Sources/App/Migrations/",
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
                fromDirectory: "./generators/dto/",
                toDirectory: "./DataTypes/Sources/DataTypes/",
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
                fromDirectory: "./generators/migration/",
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
                fromDirectory: "./generators/backend-service/",
                toDirectory: "Sources/App/Services/",
                nestToDirectory: "__CAPNAME__Service/",
                templates: [
                    "__CAPNAME__Service.swift.template",
                ]
            ),
            FileConfig(
                fromDirectory: "./generators/backend-service/",
                toDirectory: "Tests/AppTests/Services/",
                nestToDirectory: "__CAPNAME__ServiceTests/",
                templates: [
                    "__CAPNAME__ServiceIntegrationTests.swift.template",
                    "__CAPNAME__ServiceUnitTests.swift.template",
                ]
            ),
        ]
    ),
    FileType(
        name: "backend-interactor",
        configurations: [
            FileConfig(
                fromDirectory: "./generators/controller-interactor/",
                toDirectory: "../App/AutomaAppShared/Sources/AutomaAppShared/Interactors/",
                nestToDirectory: "",
                templates: [
                    "__CAPNAME__ControllerInteractor.swift.template",
                ]
            ),
            FileConfig(
                fromDirectory: "./generators/controller-interactor/",
                toDirectory: "../App/AutomaAppShared/Tests/ControllerInteractors/",
                nestToDirectory: "__CAPNAME__ControllerTests/",
                templates: [
                    "__CAPNAME__ControllerInteractorUnitTests.swift.template",
                    "__CAPNAME__ControllerInteractorIntegrationTests.swift.template",
                ]
            ),
        ]
    ),
    FileType(
        name: "async-job",
        configurations: [
            FileConfig(
                fromDirectory: "./generators/backend-async-job/",
                toDirectory: "Sources/App/Procs/Jobs/",
                nestToDirectory: "__CAPNAME__AsyncJob/",
                templates: [
                    "__CAPNAME__AsyncJob.swift.template",
                ]
            ),
            FileConfig(
                fromDirectory: "./generators/backend-async-job/",
                toDirectory: "Tests/Procs/Jobs/",
                nestToDirectory: "__CAPNAME__AsyncJobTests/",
                templates: [
                    "__CAPNAME__AsyncJobUnitTests.swift.template",
                    "__CAPNAME__AsyncJobIntegrationTests.swift.template",
                ]
            ),
        ]
    ),
    FileType(
        name: "command",
        configurations: [
            FileConfig(
                fromDirectory: "./generators/command/",
                toDirectory: "Sources/App/Commands/",
                nestToDirectory: "",
                templates: [
                    "__CAPNAME_LOWER__.swift.template",
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

        for fileType in fileTypes {
            guard fileType.name == signature.component else { continue }

            for fileConfig in fileType.configurations {
                let fromDirectory = fileConfig.fromDirectory
                let toDirectory = fileConfig.toDirectory
                let nestedDir = signature.nestedDir ?? ""
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

                    // Ignore this check when we are copying by appending !copy
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

                print("Successfully created a \(fileType.name) called '\(componentName)' in '\(toNestedDir)'.")
            }
        }

        if copy {
            let shell = Shell()

            let commandOutput = shell.run("echo '\(output)' | pbcopy")
        }
    }

    func moveAndRenameFile(source: String, destination: String, componentName: String,
                           shouldWrite: Bool = true) throws -> String
    {
        // Check if the source file exists before trying to read it
        guard FileManager.default.fileExists(atPath: source) else {
            throw Abort(.notFound, reason: "Template file not found: \(source)")
        }

        // Read the file content
        var content = try String(contentsOfFile: source, encoding: .utf8)

        // Rename occurrences of __CAPNAME__ in the content
        content = rename(text: content, componentName: componentName)

        // Write the content to the new file
        if shouldWrite {
            try content.write(toFile: destination, atomically: true, encoding: .utf8)
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
