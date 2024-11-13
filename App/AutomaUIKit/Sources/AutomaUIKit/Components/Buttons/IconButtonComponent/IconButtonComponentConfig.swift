import SwiftUI

enum IconButtonVariants {
    case variant1, variant2

}

struct IconButtonComponentConfig {
    var someProperty: String = "Default Value"  // Default value
    var variant: IconButtonVariants = .variant1

    let textColor: Color = .black
}
