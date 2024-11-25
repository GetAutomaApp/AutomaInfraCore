// InfoPairComponentConfig.swift
// was created on 11/24/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

enum InfoPairVariants {
  case variant1, variant2
}

struct InfoPairComponentConfig {
  var someProperty: String = "Default Value" // Default value
  var variant: InfoPairVariants = .variant1

  let textColor: Color = .black
}
