import SwiftUI

struct OnboardingScreenTemplateComponent: View {
    var config: OnboardingScreenTemplateComponentConfig = OnboardingScreenTemplateComponentConfig()
    var styles: OnboardingScreenTemplateComponentStyles = OnboardingScreenTemplateComponentStyles()
    
    var body: some View {
        Text("Hello, OnboardingScreenTemplate!")
            .foregroundColor(styles.textColor)
    }
}
