// ButtonFrameComponentConfig.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp. All rights reserved.

import SwiftUI

/// Enum representing the different visual variants of the button.
/// All variants are displayed int he `ButtonFrameComponent_Previews.swift` file
enum ButtonFrameVariants: String, CaseIterable {
  case generic, disabled, rainbow
}

/// Configuration class for customizing the appearance and behavior of buttons.
class ButtonFrameComponentConfig: ObservableObject {
  /// The variant of the button's appearance (e.g., generic, disabled, or rainbow).
  @Published var frameVariant: ButtonFrameVariants = .generic

  /// Determines if the button should expand to fill the available space or resize based on its content.
  @Published var fillSpace: Bool = true

  /// If `true`, makes the button circular. Overrides `roundness` with `CGFloat.infinity`.
  @Published var isCircular: Bool = false

  /// Corner radius for the button. Ignored if `isCircular` is `true`.
  @Published var roundness = DesignTokens.defaultCornerRadius

  /// Background color for the generic button variant (default is the primary color).
  @Published var variantGenericBackground = DesignTokens.colors.primary

  /// Background color for the disabled button variant (default is a lighter primary color).
  @Published var variantDisabledBackground = DesignTokens.colors.primaryWhitespace3

  /// Default padding for the button’s content.
  @Published var defaultPadding = DesignTokens.padding.button
}
