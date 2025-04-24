// GenerateAppComponentTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation

/// Represents a file type with its configurations for generating components.
internal struct FileType {
    /// The name of the file type.
    public let name: String
    /// The configurations associated with the file type.
    public let configurations: [FileConfig]
}

/// Represents a configuration for a file type.
internal struct FileConfig {
    /// The directory from which templates are sourced.
    public let fromDirectory: String
    /// The directory to which files are generated.
    public let toDirectory: String
    /// The directory to nest the generated files into.
    public let nestToDirectory: String
    /// The list of templates used for generation.
    public let templates: [String]
}

/// Represents a file type with configurations for adding to existing files.
internal struct AddToFileType {
    /// The name of the file type.
    public let name: String
    /// The configurations associated with the file type.
    public let configurations: [AddToFileConfig]
}

/// Represents a configuration for adding to an existing file.
internal struct AddToFileConfig {
    /// The template used for adding content.
    public let template: String
    /// The file to which content is added.
    public let addToFile: String
}

internal enum GenerateAppComponentFileTypeHelper {
    // Base paths for various directories
    public static let baseAppPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .deletingLastPathComponent()
        .appendingPathComponent("App")
        .standardized.path + "/"
    public static let baseDataTypesPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .deletingLastPathComponent()
        .appendingPathComponent("Backend/DataTypes")
        .standardized.path + "/"
    public static let baseBackendAppPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .deletingLastPathComponent()
        .appendingPathComponent("Backend/Sources/App")
        .standardized.path + "/"

    public static func getFileTypes() -> [FileType] {
        [
            FileType(name: "ui-component", configurations: [
                FileConfig(
                    fromDirectory: "ui-component/",
                    toDirectory: "\(baseAppPath)AutomaUIKit/Sources/AutomaUIKit/Components/",
                    nestToDirectory: "__CAPNAME__Component/",
                    templates: [
                        "__CAPNAME__Component.swift.template",
                        "__CAPNAME__ComponentPreviews.swift.template",
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
                        "__CAPNAME__ModifierPreviews.swift.template",
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
                        toDirectory: "./Sources/App/Models/",
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
                        toDirectory: "Sources/App/Services/",
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
    }
}
