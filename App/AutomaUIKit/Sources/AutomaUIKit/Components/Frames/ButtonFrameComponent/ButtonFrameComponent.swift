import SwiftUI

struct ButtonFrameComponent<Content: View>: View {
    @StateObject var config = ButtonFrameComponentConfig()
    
    let action: (ButtonFrameComponentConfig) -> Void
    var content: (ButtonFrameComponentConfig) -> Content

    
    var body: some View {
        Button(action: {
            action(config)
        }) {
            content(config)
                .frame(maxWidth: config.fillSpace ? .infinity : nil)
                .padding(DesignTokens.padding.button)
                .background(
                    config.frameVariant == .generic ? config.variantGenericBackground : config.variantGenericBackground.opacity(0)
                )
                .cornerRadius(config.isCircular ? .infinity : config.roundness)
        }
    }
}
