import SwiftUI

struct InfoPairComponent: View {
    var config: InfoPairComponentConfig = InfoPairComponentConfig()

    var body: some View {
        VStack(alignment: .leading){
            Text("Enter a title here").fontTableFont(FontTable.Headings.head4)
            Text("Enter a 3 line / 2 line description here").fontTableFont(FontTable.Body.body1)
        }
    }
}
