// ButtonFrameComponent_Previews.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp. All rights reserved.

import SwiftUI

struct ButtonFrameComponent_Previews: PreviewProvider {
  static var previews: some View {
    ButtonFrameComponent_PreviewsView()
  }
}

struct ButtonFrameComponent_PreviewsView: View {
  @StateObject var buttonConfig: ButtonFrameComponentConfig = .init()

  var body: some View {
    Form {
      // Customizable Button Section
      Section {
        Text("Customize Button Variants")

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

        // MARK: - Customization Controls

        VStack(alignment: .leading) {
          Text("Frame Variant")
          Picker("Button Variant", selection: $buttonConfig.frameVariant) {
            ForEach(ButtonFrameVariants.allCases, id: \.self) { variant in
              Text(variant.rawValue)
            }
          }
          .pickerStyle(SegmentedPickerStyle())
          .padding(.bottom)

          Toggle("Fill Space", isOn: $buttonConfig.fillSpace)

          Toggle("Circular", isOn: $buttonConfig.isCircular)
            .padding(.bottom)

          VStack(alignment: .leading) {
            Text("Corner Roundness: \(Int(buttonConfig.roundness))")
            HStack {
              Slider(value: $buttonConfig.roundness, in: 0 ... 50, step: 1)

              ButtonFrameComponent(action: {
                buttonConfig.roundness = DesignTokens.defaultCornerRadius
              }) {
                Text("Reset")
              } onSelfAppear: { config in
                config.fillSpace = false
              }
            }
          }
        }
        .padding(.top)
      }

      Section {
        Text("Auto Variant & Variations")
        AutoButtonVariationsView()
      }

      Section {
        Text("Button Variants")
        ButtonFrameComponent(action: {}) {
          Text("generic")
        }
        ButtonFrameComponent(action: {}) {
          Text("disabled")
        } onSelfAppear: { config in
          config.frameVariant = .disabled
        }
        ButtonFrameComponent(action: {}) {
          Text("rainbow")
        } onSelfAppear: { config in
          config.frameVariant = .rainbow
        }
      }

    }.padding(.top, 30)
      .ignoresSafeArea()
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
