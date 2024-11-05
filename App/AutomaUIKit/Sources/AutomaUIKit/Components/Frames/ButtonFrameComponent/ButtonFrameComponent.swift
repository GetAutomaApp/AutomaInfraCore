import SwiftUI

struct ButtonFrameComponent: View {
    var config: ButtonFrameComponentConfig = ButtonFrameComponentConfig()
    var styles: ButtonFrameComponentStyles = ButtonFrameComponentStyles()
    
    var body: some View {
        Text("Hello, ButtonFrame!")
            .foregroundColor(styles.textColor)
    }
}
