import SwiftUI

struct ButtonFrameComponent<Content: View>: View {
    @StateObject var config = ButtonFrameComponentConfig()
    
    var content: (ButtonFrameComponentConfig) -> Content
    let action: (ButtonFrameComponentConfig) -> Void
    
    
    var body: some View {
        Button(action: {
            action(config)
            config.isCircular.toggle()
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
