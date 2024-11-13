import SwiftUI

struct IconButtonComponent: View {
    var config: IconButtonComponentConfig = IconButtonComponentConfig()

    var body: some View {
        Text("Hello, IconButton!")
            .foregroundColor(config.textColor)
    }
}
