# FontTableFontModifier

## Overview
The FontTableFontModifier is a crucial view modifier in the AutomaUIKit framework designed to provide consistent typography across your application. It enables developers to apply predefined font styles from the FontTable to Text views with ease, ensuring design system consistency and reducing manual font styling throughout the app.

The `fontTableFont` modifier solves the following issues throughout the app:
- Standardizes the appearance and usage of our custom fonts across the ui library
- Simplifies the application of these fonts by abstracting them in the `FontManager` table in the `Tokens.swift` file.


## Design
LINK: [Figma](https://www.figma.com/design/x5MkR0UFRMUkp0eiAXVbmy/AutomaUIKit?node-id=635-254)

## Usage
<!-- Explain how to use the view modifier here -->
<!-- Ensure to provide at-least one example per initializer to make the user understand the scope of the component -->
<!-- Add one image per initializer (This is UI after all) -->
Using the fontModifierFont is super simple, currently we only support this this modifier being used on the SwiftUI `Text` element.

```swift
Text("This is a custom font").fontManagerFont(FontTable.Body.h1, .red)
```

## Props/Parameters
| Property | Type | Description |
|----------|------|-------------|
| `content` | `FontTableFontModifierViewTypes` | The View to be modified in the custom view modifier |
| `colour` | `Color` | The colour you want the font to be, defaults to the system default.

## Guidelines
<!-- Explain when and when not to use this view modifier based on past experience -->
- Use this for every single text element being rendered to the screen unless the design requiremens strictly specifies otherwhise

## Customization
<!-- Give a detailed explanation on how to make the most use of this new modifier -->
- Customising this Initializer can be done throught he `colour` property, as well as an added benefit of more custom fonts being loaded by providing them in the assets directory.

Here is how to add custom fonts:
1. Download all the variations of that font you want to apply
2. Put all of these fonts in `Sources/Assets/Fonts` ensuring that they all are prefixed with their type, ex: `TestFont-regular.ttf`
3. Run `swiftgen` to generate the fonts file in `Core/Generated/Fonts.swift`
4. Add these fonts to the `FontTable` in the design tokens, ensuring that any new enums conform to `IsFontTable`.
5. Test the usage of these new fonts by applying the modifier!

fontTableFont
