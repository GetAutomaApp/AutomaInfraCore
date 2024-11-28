// Tokens.swift
// was created on 11/28/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

struct DesignColors {
    let primary: Color = .init(hex: "0FA958")

    /// Text Colours
    let primaryText: Color = .init(hex: "FFFFFF")
    let secondaryText: Color = .init(hex: "B4B4B4")
    let textDark: Color = .init(hex: "00000")

    /// Whitespace Colours
    let primaryWhitespace1: Color = .init(hex: "000000")
    let primaryWhitespace2: Color = .init(hex: "3C3C3C")
    let primaryWhitespace3: Color = .init(hex: "7C7C7C")
}

struct DesignPadding {
    let button: EdgeInsets = .init(top: 10, leading: 20, bottom: 10, trailing: 20)
    let buttonEven: EdgeInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
}

enum DesignIconsEnum: CaseIterable {
    case pause, play, unknown

    var image: some View {
        switch self {
        case .pause:
            Image(systemName: "pause.circle.fill").toIcon()
        case .play:
            Image(systemName: "play.circle.fill").toIcon()
        case .unknown:
            Image(systemName: "questionmark.circle.fill").toIcon()
        }
    }
}

struct DesignIcons {
    let defaultWidth: CGFloat = 24
    let defaultHeight: CGFloat = 24
}

enum DesignTokens {
    static let colors: DesignColors = .init()
    static let padding: DesignPadding = .init()
    static let icons: DesignIcons = .init()

    static let defaultCornerRadius: CGFloat = 8
}

protocol IsFontTableFont {
    var font: SwiftUI.Font { get }
}

enum FontTable {
    enum Headings: IsFontTableFont {
        case head1
        case head2
        case head3
        case head4
        case head5
        case head6

        var font: SwiftUI.Font {
            switch self {
            case .head1:
                FontFamily.CrimsonText.bold.swiftUIFont(size: 60)
            case .head2:
                FontFamily.CrimsonText.bold.swiftUIFont(size: 48)
            case .head3:
                FontFamily.CrimsonText.bold.swiftUIFont(size: 36)
            case .head4:
                FontFamily.CrimsonText.bold.swiftUIFont(size: 30)
            case .head5:
                FontFamily.CrimsonText.bold.swiftUIFont(size: 24)
            case .head6:
                FontFamily.CrimsonText.bold.swiftUIFont(size: 20)
            }
        }
    }

    enum Body: IsFontTableFont {
        case body1
        case body2
        case body3
        case body4

        var font: SwiftUI.Font {
            switch self {
            case .body1:
                FontFamily.CrimsonText.regular.swiftUIFont(size: 20)
            case .body2:
                FontFamily.CrimsonText.regular.swiftUIFont(size: 18)
            case .body3:
                FontFamily.CrimsonText.regular.swiftUIFont(size: 16)
            case .body4:
                FontFamily.CrimsonText.regular.swiftUIFont(size: 14)
            }
        }
    }

    enum Meta: IsFontTableFont {
        case label1, label2, caption1

        var font: SwiftUI.Font {
            switch self {
            case .label1:
                FontFamily.CrimsonText.regular.swiftUIFont(size: 14)
            case .label2:
                FontFamily.CrimsonText.regular.swiftUIFont(size: 12)
            case .caption1:
                FontFamily.CrimsonText.regular.swiftUIFont(size: 12)
            }
        }
    }

//    enum Italics {
//        enum Body: IsFontTableFont {
//        }
//        enum Meta: IsFontTableFont {
//        }
//    }
}
