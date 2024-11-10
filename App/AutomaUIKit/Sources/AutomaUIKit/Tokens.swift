// Tokens.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp. All rights reserved.

import SwiftUI

struct DesignColors {
  let primary: Color = .init(hex: "0FA958")
  let primaryWhitespace3: Color = .init(hex: "7C7C7C")
}

struct DesignPadding {
  let button: EdgeInsets = .init(top: 10, leading: 20, bottom: 10, trailing: 20)
}

enum DesignTokens {
  static let colors: DesignColors = .init()
  static let padding: DesignPadding = .init()

  static let defaultCornerRadius: CGFloat = 8
}
