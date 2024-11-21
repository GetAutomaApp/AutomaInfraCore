// IconButtonComponent_Previews.swift
// AdonisCodes created this file on 11/6/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

struct IconButtonComponent_Previews: PreviewProvider {
  static var previews: some View {
    IconButtonComponent(
        onSelfAppear: {
            config in config.isDisabled = true}, defaultIcon: .pause, action: { config in
        config.variant = .allCases.randomElement()!
          config.icon = .allCases.randomElement()!
      }
    ).padding()
  }
}
