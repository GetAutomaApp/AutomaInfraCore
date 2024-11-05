enum ButtonFrameVariants {
    case variant1, variant2
    
}

struct ButtonFrameComponentConfig {
    var someProperty: String = "Default Value"  // Default value
    var variant: ButtonFrameVariants = .variant1
}
