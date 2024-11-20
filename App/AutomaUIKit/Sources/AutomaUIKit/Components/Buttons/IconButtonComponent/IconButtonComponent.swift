// IconButtonComponent.swift
// AdonisCodes created this file on 11/13/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

struct IconButtonComponent: View {
  @StateObject var config: IconButtonComponentConfig

  let onSelfAppear: (IconButtonComponentConfig) -> Void
  let action: (IconButtonComponentConfig) -> Void


  init(
    config: IconButtonComponentConfig = .init(),
    /// onSelfAppear can override any properties that gets initialized in the init!
    onSelfAppear: @escaping (IconButtonComponentConfig) -> Void = { _ in },
    /// defaultIcon overrides anything you pass in into the config!
    defaultIcon: DesignIconsEnum = .unknown,
    action: @escaping (IconButtonComponentConfig) -> Void = { _ in }
  ) {
    config.icon = defaultIcon
    _config = StateObject(wrappedValue: config)
    self.onSelfAppear = onSelfAppear
    self.action = action
  }

  var body: some View {
    ButtonFrameComponent(config: config.frameConfig, action: { _ in
        action(config)
    }) {
      iconToUse
    } onSelfAppear: { _ in
      // NOTE: We have access to the `internalConfig` from the `config.frameConfig
      onSelfAppear(config)
      print(config)
    }
    .contentTransition(.symbolEffect(.replace))
  }

  var iconToUse: some View {
    switch config.variant {
    case .generic:
      config.icon.image
    default:
      DesignIconsEnum.pause.image
    }
  }
}
