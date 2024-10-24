import SwiftUI

struct __CAPNAME__Component: View {
    var config: __CAPNAME__ComponentConfig = __CAPNAME__ComponentConfig()
    var styles: __CAPNAME__ComponentStyles = __CAPNAME__ComponentStyles()
    
    var body: some View {
        Text("Hello, __CAPNAME__!")
            .foregroundColor(styles.textColor)
    }
}
