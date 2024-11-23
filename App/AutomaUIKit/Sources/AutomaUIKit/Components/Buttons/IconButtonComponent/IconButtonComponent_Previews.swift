import SwiftUI

struct IconButtonComponent_Previews: PreviewProvider {
    static var previews: some View {
        IconButtonComponent_PreviewsView()
    }
}

struct IconButtonComponent_PreviewsView: View {
    @StateObject private var sharedConfig = IconButtonComponentConfig()
    
    var body: some View {
        PropertyEditor(
            object: sharedConfig,
          properties: [
            [AnyKeyPath("Is Disabled", keyPath: \.isDisabled)],
            [AnyKeyPath("Fill Space", keyPath: \.fillSpace)],
            [AnyKeyPath("Is Circular", keyPath: \.isCircular)],
            [AnyKeyPath("Padding", keyPath: \.defaultPadding)],
            [AnyKeyPath("Roundness", keyPath: \.roundness)],
            [AnyKeyPath("Generic Background", keyPath: \.variantGenericBackground)],
            [AnyKeyPath("Disabled Background", keyPath: \.variantDisabledBackground)],
          ]
        ) {
          VStack {
              HStack {
                  IconButtonComponent(config: sharedConfig, onSelfAppear: {config in
                      config.icon = .play
                  },
                                      action: { config in
                      if config.icon == .play {
                          config.icon = .pause
                      } else {
                          config.icon = .play
                      }
                      
                      
                  }
                  ).contentTransition(.symbolEffect(.replace))
              }

            EnumPropertyView(
                value: $sharedConfig.frameVariant,
              cases: ButtonFrameVariants.allCases
            )
              
              EnumPropertyView(
                  value: $sharedConfig.variant,
                  cases: IconButtonVariants.allCases
              )
          }
        }
    }
}
