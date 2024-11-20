// IconButtonComponentConfig.swift
// Simon Ferns created this file on 10/23/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

enum IconButtonVariants: String, CaseIterable {
  case generic
  case square
  case circle
  case pill

  // MARK: - Special Variants / Widely Used Buttons

  case play
  case videoPlay
  case pause
  case videoPause
  case cancel
}

class IconButtonComponentConfig: ObservableObject {
  @Published var frameConfig: ButtonFrameComponentConfig = .init()
  @Published var variant: IconButtonVariants = .generic
  @Published var icon: DesignIconsEnum = .unknown

//    init(frameConfig: ButtonFrameComponentConfig = .init(), variant: IconButtonVariants = .generic) {
//        self._frameConfig = .init(initialValue: frameConfig)
//        self._variant = .init(initialValue: variant)
//    }
}
