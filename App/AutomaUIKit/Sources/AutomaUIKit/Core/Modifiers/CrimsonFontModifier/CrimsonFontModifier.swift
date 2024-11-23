import SwiftUI

/**
The `CrimsonFontModifier` is a view modifier that ___

Add a detailed description here of how to use this

- Parameters:
    - content: The SwiftUI view being modified.
- Returns: some View

To see usage examples & visuals, check out `CrimsonFontModifierDocumentation.md`
*/
struct CrimsonFontModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            // Add your custom modifications here
    }
}

typealias CrimsonFontModifierViewTypes = View // Use Type Narrowing Please!

extension CrimsonFontModifierViewTypes {
    func crimsonFont() -> some View {
        self.modifier(CrimsonFontModifier())
    }
}