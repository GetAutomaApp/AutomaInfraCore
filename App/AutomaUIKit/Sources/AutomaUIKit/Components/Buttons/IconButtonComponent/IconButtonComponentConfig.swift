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
