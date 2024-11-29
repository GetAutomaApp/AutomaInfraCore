// FontTableFontModifier.swift
// was created on 11/28/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

/**
 The `FontTableFontModifier` is a view modifier used to apply fonts from the `FontTable` to `Text` views in SwiftUI.
 It allows you to use custom font styles defined in the `FontTable` enums, ensuring consistency across your app.

 This modifier takes an object conforming to the `IsFontTableFont` protocol, which provides access to the appropriate `Font` instance.
 By using this modifier, you can apply predefined fonts that are part of the `FontTable`, including headings, body text, and meta labels.

 - Parameters:
     - fontTableType: A value conforming to the `IsFontTableFont` protocol, which provides the corresponding `SwiftUI.Font`.

 - Returns: A `View` with the specified font applied.

 ### Usage Examples:

 #### Basic Example:
 To apply a heading font (e.g., `h1`) from the `FontTable.Headings` enum to a `Text` view:

 ```swift
 Text("This is a Heading 1!")
     .fontTableFont(FontTable.Headings.h1)

 Text("This is a Heading 1!")
     .fontTableFont(FontTable.Headings.h1, .black)
 ```
 */
public struct FontTableFontModifier: ViewModifier {
    let fontTableType: IsFontTableFont
    let colour: Color?

    public func body(content: Content) -> some View {
        if let colour {
            content.font(fontTableType.font).foregroundStyle(colour)
        } else {
            content.font(fontTableType.font)
        }
    }
}

public typealias FontTableFontModifierViewTypes = Text // Use Type Narrowing Please!

@MainActor
public extension FontTableFontModifierViewTypes {
    func fontTableFont(_ font: IsFontTableFont, _ colour: Color? = nil) -> some View {
        modifier(FontTableFontModifier(fontTableType: font, colour: colour))
    }
}
