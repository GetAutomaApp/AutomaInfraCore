enum OnboardingScreenTemplateVariants {
    case variant1, variant2
    
}

struct OnboardingScreenTemplateComponentConfig {
    var someProperty: String = "Default Value"  // Default value
    var variant: OnboardingScreenTemplateVariants = .variant1
}
