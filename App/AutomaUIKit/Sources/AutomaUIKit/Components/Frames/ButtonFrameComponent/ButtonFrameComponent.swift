// ButtonFrameComponent.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp. All rights reserved.

import SwiftUI

// Define the ButtonFrameComponent
struct ButtonFrameComponent<Content: View>: View {
  // Default button config state that will be used if manual configuration isn't provided
  @StateObject private var config = ButtonFrameComponentConfig()

  let action: (ButtonFrameComponentConfig) -> Void
  let onSelfAppear: (ButtonFrameComponentConfig) -> Void
  var content: (ButtonFrameComponentConfig) -> Content

  // MARK: - Initializer 1: Action has config, content doesn't

  init(config: ButtonFrameComponentConfig? = nil,
       action: @escaping (ButtonFrameComponentConfig) -> Void,
       @ViewBuilder content: @escaping () -> Content,
       onSelfAppear: @escaping (ButtonFrameComponentConfig) -> Void = { _ in })
  {
    let selfConfigDefault = ButtonFrameComponentConfig()
    _config = StateObject(wrappedValue: config ?? selfConfigDefault)

    self.action = action
    self.onSelfAppear = onSelfAppear
    self.content = { _ in content() }
  }

  // MARK: - Initializer 2: Content has config, action doesn't

  init(config: ButtonFrameComponentConfig? = nil,
       action: @escaping () -> Void,
       @ViewBuilder content: @escaping (ButtonFrameComponentConfig) -> Content,
       onSelfAppear: @escaping (ButtonFrameComponentConfig) -> Void = { _ in })
  {
    let selfConfigDefault = ButtonFrameComponentConfig()
    _config = StateObject(wrappedValue: config ?? selfConfigDefault)

    self.action = { _ in action() }
    self.onSelfAppear = onSelfAppear
    self.content = content
  }

  // MARK: - Initializer 3: Neither action nor content use config

  init(config: ButtonFrameComponentConfig? = nil,
       action: @escaping () -> Void,
       @ViewBuilder content: @escaping () -> Content,
       onSelfAppear: @escaping (ButtonFrameComponentConfig) -> Void = { _ in })
  {
    let selfConfigDefault = ButtonFrameComponentConfig()
    _config = StateObject(wrappedValue: config ?? selfConfigDefault)

    self.action = { _ in action() }
    self.onSelfAppear = onSelfAppear
    self.content = { _ in content() }
  }

  // MARK: - Initializer 4: Both action and content use config

  init(config: ButtonFrameComponentConfig? = nil,
       action: @escaping (ButtonFrameComponentConfig) -> Void,
       @ViewBuilder content: @escaping (ButtonFrameComponentConfig) -> Content,
       onSelfAppear: @escaping (ButtonFrameComponentConfig) -> Void = { _ in })
  {
    let selfConfigDefault = ButtonFrameComponentConfig()
    _config = StateObject(wrappedValue: config ?? selfConfigDefault)

    self.action = action
    self.onSelfAppear = onSelfAppear
    self.content = content
  }

  var body: some View {
    Button(action: {
      action(config)
    }) {
      content(config)
        .frame(maxWidth: config.fillSpace ? .infinity : nil) // Ensure fixed size when fillSpace is false
        .padding(config.defaultPadding) // Zero padding if defaultPadding is 0
        .background(determineBackgroundColor()) // Set the background
    }
    .buttonStyle(PlainButtonStyle()) // Remove the default button padding
    .cornerRadius(config.isCircular ? .infinity : config.roundness)
    .disabled(config.frameVariant == .disabled)
    .frame(minWidth: 0, minHeight: 0)
    .onAppear {
      onSelfAppear(config)
    }
  }

  // This function returns a specific view for each background variant
  func determineBackgroundColor() -> some View {
    Group {
      switch config.frameVariant {
      case .disabled:
        config.variantDisabledBackground
      case .generic:
        config.variantGenericBackground
      case .rainbow:
        LinearGradient(
          gradient: Gradient(colors: [.blue, .purple]),
          startPoint: .top,
          endPoint: .bottom
        )
      }
    }
  }
}
