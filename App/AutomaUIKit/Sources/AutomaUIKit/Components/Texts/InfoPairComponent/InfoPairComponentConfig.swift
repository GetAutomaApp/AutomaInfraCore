import SwiftUI

enum InfoPairVariants {
    case variant1, variant2

}

struct InfoPairComponentConfig {
    var someProperty: String = "Default Value"  // Default value
    var variant: InfoPairVariants = .variant1

    let textColor: Color = .black
}
