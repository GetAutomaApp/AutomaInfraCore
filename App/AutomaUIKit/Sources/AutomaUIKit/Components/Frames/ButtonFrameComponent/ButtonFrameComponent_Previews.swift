import SwiftUI

struct ButtonFrameComponent_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ButtonFrameComponent() {config in
                Text(config.fillSpace.description)
            } action: {_ in}
            .padding()
        }
    }
}
