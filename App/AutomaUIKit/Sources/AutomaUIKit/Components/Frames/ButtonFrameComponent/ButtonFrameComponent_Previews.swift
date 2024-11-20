// ButtonFrameComponent_Previews.swift
// AdonisCodes created this file on 11/6/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

struct ButtonFrameComponent_Previews: PreviewProvider {
  static var previews: some View {
    ButtonFrameComponent_PreviewsView()
  }
}

struct ButtonFrameComponent_PreviewsView: View {
  @StateObject var buttonConfig: ButtonFrameComponentConfig = .init()

  var body: some View {
    PropertyEditor(
      object: buttonConfig,
      properties: [
        [AnyKeyPath("Fill Space", keyPath: \.fillSpace)],
        [AnyKeyPath("Is Circular", keyPath: \.isCircular)],
        [AnyKeyPath("Padding", keyPath: \.defaultPadding)],
        [AnyKeyPath("Roundness", keyPath: \.roundness)],
        [AnyKeyPath("Generic Background", keyPath: \.variantGenericBackground)],
        [AnyKeyPath("Disabled Background", keyPath: \.variantDisabledBackground)],
      ]
    ) {
      VStack {
        AutoButtonVariationsView()
        HStack {
          ButtonFrameComponent(config: buttonConfig, action: {
            print("Clicked Me")
          }) {
            Text("Hello, World")
          }

          ButtonFrameComponent(config: buttonConfig, action: {
            print("Clicked Me")
          }) {
            Image(systemName: "play.fill")
          }
        }

        EnumPropertyView(
          value: $buttonConfig.frameVariant,
          cases: ButtonFrameVariants.allCases
        )
      }
    }
  }
}

struct AutoButtonVariationsView: View {
  @StateObject var buttonController: ButtonFrameComponentConfig = .init()
  @State private var isTimerActive = false

  let switchDelay: TimeInterval = 0.5

  var body: some View {
    HStack {
      ButtonFrameComponent(config: buttonController, action: { config in
        config.isCircular.toggle()
        config.frameVariant = .disabled
      }) { _ in
        ProgressView()
      } onSelfAppear: { _ in
        startChangingVariant()
      }

      Spacer()

      ButtonFrameComponent(action: { _ in
        isTimerActive ? stopChangingVariant() : startChangingVariant()
      }) {
        isTimerActive ? DesignIconsEnum.pause.image : DesignIconsEnum.play.image
      } onSelfAppear: { config in
        config.fillSpace = false
      }
      .contentTransition(.symbolEffect(.replace))
    }
  }

  func startChangingVariant() {
    if isTimerActive {
      return
    }

    isTimerActive = true

    DispatchQueue.main.asyncAfter(deadline: .now() + switchDelay) {
      updateVariant()
    }
  }

  func updateVariant() {
    buttonController.frameVariant = .allCases.randomElement()!
    buttonController.isCircular = .random()
    buttonController.fillSpace = .random()

    if isTimerActive {
      DispatchQueue.main.asyncAfter(deadline: .now() + switchDelay) {
        updateVariant()
      }
    }
  }

  func stopChangingVariant() {
    isTimerActive = false
  }
}
