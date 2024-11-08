import SwiftUI

struct ButtonFrameComponent_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ButtonFrameComponent(action: {config in
                config.isCircular.toggle()
            }) {config in
                Text(config.fillSpace.description)
            }
            .padding()
        }
    }
}
