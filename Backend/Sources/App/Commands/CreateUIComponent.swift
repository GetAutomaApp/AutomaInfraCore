import Vapor

struct GenerateUIComponentCommand: Command {
    var help: String {
        "Generates a UI Component to speed up development experience."
    }

    struct Signature: CommandSignature {
        @Argument(name: "name", help: "The name of the component to generate.")
        var filename: String
    }

    func run(using context: CommandContext, signature: Signature) throws {
        let fileManager = FileManager.default
        
        // Capitalize the component name
        let componentName = signature.filename.capitalized
        let componentDirectory = "../App/AutomaUIKit/AutomaUIKit/Sources/AutomaUIKit/Components/\(componentName)Component"
        
        // Check if the component directory already exists
        if fileManager.fileExists(atPath: componentDirectory) {
            context.console.print("Directory \(componentDirectory) already exists.")
            return
        }
        
        // Create the component directory
        try fileManager.createDirectory(atPath: componentDirectory, withIntermediateDirectories: true, attributes: nil)

        // Define the file contents
        let mainFileContent = """
        import SwiftUI

        struct \(componentName)Component: View {
            var config: \(componentName)ComponentConfig = \(componentName)ComponentConfig()
            var styles: \(componentName)ComponentStyles = \(componentName)ComponentStyles()
            
            var body: some View {
                Text("Hello, \(componentName)!")
                    .foregroundColor(styles.textColor)
            }
        }
        """

        let implementationFileContent = """
        import Foundation

        extension \(componentName)Component {
            // Add your implementations here
            let name: String = "HI"
        
            func printName() {
                print(name)
            }
        }
        """

        let previewsFileContent = """
        // Add your previews here
        import SwiftUI

        struct \(componentName)Component_Previews: PreviewProvider {
            static var previews: some View {
                \(componentName)Component()
            }
        }
        """

        let stylesFileContent = """
        import SwiftUI

        struct \(componentName)ComponentStyles {
            var textColor: Color = .black  // Default value
            // Add more style properties as needed
        }
        """

        let configFileContent = """
        struct \(componentName)ComponentConfig {
            var someProperty: String = "Default Value"  // Default value
            // Add more configuration properties as needed
        }
        """

        let documentationFileContent = """
        # \(componentName)Component
        
        ## Overview
        <!-- Give a reason behind this component & what it is doing -->
        
        ## Design
        LINK: <!-- Link to the figma file component here -->
        <!-- Explain the Design of the componente -->
        
        ## Usage
        <!-- Explain how to use the component here -->
        
        ## Props/Parameters
        | Property | Type | Description |
        |----------|------|-------------|
        | `config` | \(componentName)ComponentConfig | Configuration for the component. |
        | `styles` | \(componentName)ComponentStyles | Styles for the component. |

        ## Events/Callbacks
        | Event | Description |
        |-------|-------------|
        | `onTap` | Triggered when the component is tapped. |

        ```swift
        import AutomaUIKit
        
        ...
        let myComponent = \(componentName)Component(config: \(componentName)ComponentConfig(someProperty: "Custom Value"), styles: \(componentName)ComponentStyles(textColor: .red))
        ...
        
        ## Guidelines
        <!-- Explain when and when not to use the component based on past experience -->
        
        ## Customization
        <!-- Explain how users can customize the component via the "Config" object in \(componentName)ComponentConfig Struct -->
        <!-- Explain how users can customize the styles via the "Style" object in \(componentName)ComponentStyles Struct -->
        
        ## StyleConfig
        <!-- Explain how the "StyleConfig.swift" file has an influence on how the components are styled by default. -->
        """
        
        // Create the asset catalog
        let assetsDirectory = "\(componentDirectory)/\(componentName)Component.xcassets"
        try fileManager.createDirectory(atPath: assetsDirectory, withIntermediateDirectories: true, attributes: nil)
        
        // Create the Contents.json file for the asset catalog
        let contentsJSON = """
        {
            "images": [],
            "info": {
                "version": 1,
                "author": "xcode"
            }
        }
        """
        
        let contentsFilePath = "\(assetsDirectory)/Contents.json"
        try contentsJSON.write(to: URL(fileURLWithPath: contentsFilePath), atomically: true, encoding: .utf8)
        
        // Create all the required files
        let files = [
            ("\(componentName)Component.swift", mainFileContent),
            ("\(componentName)ComponentFunctions.swift", implementationFileContent),
            ("\(componentName)Component_Previews.swift", previewsFileContent),
            ("\(componentName)ComponentStyles.swift", stylesFileContent),
            ("\(componentName)ComponentDocumentation.md", documentationFileContent),
            ("\(componentName)ComponentConfig.swift", configFileContent)
        ]
        
        // Write each file
        for (filename, content) in files {
            let filePath = "\(componentDirectory)/\(filename)"
            try content.write(to: URL(fileURLWithPath: filePath), atomically: true, encoding: .utf8)
            context.console.print("File \(filename) created successfully!")
        }

        context.console.print("Asset catalog \(componentName)Component.xcassets created successfully!")
    }
}
