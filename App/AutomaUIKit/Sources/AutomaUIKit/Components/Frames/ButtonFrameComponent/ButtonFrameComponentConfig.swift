import SwiftUI

enum ButtonFrameVariants {
    case generic, disabled
}

class ButtonFrameComponentConfig: ObservableObject {
    @Published var frameVariant: ButtonFrameVariants = .generic
    @Published var fillSpace: Bool = true
    @Published var isCircular: Bool = false

    let variantGenericBackground: Color = DesignTokens.colors.primary
    let roundness: CGFloat = 8
}
