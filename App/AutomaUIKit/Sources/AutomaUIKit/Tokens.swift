import SwiftUI

struct DesignColors {
    let primary: Color = .init(hex: "0FA958")
}

struct DesignPadding {
    let button: EdgeInsets = .init(top: 10, leading: 20, bottom: 10, trailing: 20)
}

struct DesignTokens {
    static let colors: DesignColors = .init()
    static let padding: DesignPadding = .init()
}
