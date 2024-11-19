import SwiftUI

struct IconButtonComponent: View {
  var config: IconButtonComponentConfig = .init()

  let onSelfAppear: (IconButtonComponentConfig) -> Void

  init(
    config: IconButtonComponentConfig = .init(),
    onSelfAppear: @escaping (IconButtonComponentConfig) -> Void = { _ in }
  ) {
    self.config = config
    self.onSelfAppear = onSelfAppear
  }

  var body: some View {
    ButtonFrameComponent(config: config.frameConfig, action: { _ in
      print("Action")
    }) {
      iconToUse
    } onSelfAppear: { _ in
      // NOTE: We have access to the `internalConfig` from the `config.frameConfig
      onSelfAppear(config)
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
