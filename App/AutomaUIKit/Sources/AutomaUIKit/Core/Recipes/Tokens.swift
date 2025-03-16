// Tokens.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

public struct DesignColors: Sendable {
    public let primary: Color = .init(hex: "0FA958")

    /// Text Colours
    public let primaryText: Color = .init(hex: "FFFFFF")
    public let secondaryText: Color = .init(hex: "B4B4B4")
    public let textDark: Color = .init(hex: "000000")

    /// Whitespace Colours
    public let primaryWhitespace1: Color = .init(hex: "000000")
    public let primaryWhitespace2: Color = .init(hex: "3C3C3C")
    public let primaryWhitespace3: Color = .init(hex: "7C7C7C")

    public let danger: Color = .init(hex: "FD8B83")
    public let error: Color = .init(hex: "FF3B2F")
}

public struct DesignPadding: Sendable {
    public enum PaddingSizes: CGFloat {
        case base, medium, small, large

        var value: CGFloat {
            switch self {
            case .base:
                12
            case .medium:
                8
            case .small:
                4
            case .large:
                16
            }
        }
    }

    public let button: EdgeInsets = .init(top: 20, leading: 30, bottom: 20, trailing: 30)
    public let buttonEven: EdgeInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
    public let smallPaddingVar: EdgeInsets = .init(
        top: PaddingSizes.base.value,
        leading: PaddingSizes.large.value,
        bottom: PaddingSizes.base.value,
        trailing: PaddingSizes.large.value
    )

    public let none: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    public let minimal: EdgeInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)

    public let cornerRadiusBase: CGSize = .init(
        width: PaddingSizes.base.value,
        height: PaddingSizes.base.value
    )
}

protocol DesignIcon {
    associatedtype Content: View
    var image: Content { get }
}

public enum DesignIcons: String, CaseIterable, DesignIcon {
    case pause, play, unknown
    case arrowRight

    // mathematics
    case subtraction

    // Other
    case other

    var image: some View {
        switch self {
        case .pause:
            Image(systemName: "pause.circle.fill").toIcon()
        case .play:
            Image(systemName: "play.circle.fill").toIcon()
        case .unknown:
            Image(systemName: "questionmark.circle.fill").toIcon()
        case .arrowRight:
            Image(systemName: "arrow.right").toIcon()
        case .subtraction:
            Image(systemName: "minus").toIcon()
        case .other:
            Image(systemName: "x.circle.fill").toIcon()
        }
    }
}

struct DesignIconsConfig: Sendable {
    let defaultWidth: CGFloat = 17.5
    let defaultHeight: CGFloat = 17.5
}

public enum DesignTokens {
    public static let colors: DesignColors = .init()
    public static let padding: DesignPadding = .init()
    static let icons: DesignIconsConfig = .init()

    public static let defaultCornerRadius: CGFloat = 12
}

public protocol IsFontTableFont {
    var font: SwiftUI.Font { get }
}

public enum FontTable {
    public enum Crimson {
        public enum Headings: IsFontTableFont {
            case head1
            case head2
            case head3
            case head4
            case head5
            case head6

            public var font: SwiftUI.Font {
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

        public enum Body: IsFontTableFont {
            case body1
            case body2
            case body3
            case body4

            public var font: SwiftUI.Font {
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

        public enum Meta: IsFontTableFont {
            case label1, label2, caption1

            public var font: SwiftUI.Font {
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
    }

    public enum SFPro {
        public enum Headings: IsFontTableFont {
            case head1
            case head2
            case head3
            case head4
            case head5
            case head6

            public var font: SwiftUI.Font {
                switch self {
                case .head1:
                    FontFamily.SFProText.bold.swiftUIFont(size: 60)
                case .head2:
                    FontFamily.SFProText.bold.swiftUIFont(size: 48)
                case .head3:
                    FontFamily.SFProText.bold.swiftUIFont(size: 36)
                case .head4:
                    FontFamily.SFProText.semibold.swiftUIFont(size: 30)
                case .head5:
                    FontFamily.SFProText.semibold.swiftUIFont(size: 24)
                case .head6:
                    FontFamily.SFProText.semibold.swiftUIFont(size: 18)
                }
            }
        }

        public enum Body: IsFontTableFont {
            case body1
            case body2
            case body3
            case body4

            public var font: SwiftUI.Font {
                switch self {
                case .body1:
                    FontFamily.SFProText.regular.swiftUIFont(size: 20)
                case .body2:
                    FontFamily.SFProText.regular.swiftUIFont(size: 18)
                case .body3:
                    FontFamily.SFProText.regular.swiftUIFont(size: 16)
                case .body4:
                    FontFamily.SFProText.regular.swiftUIFont(size: 14)
                }
            }
        }

        public enum Meta: IsFontTableFont {
            case label1, label2, caption1

            public var font: SwiftUI.Font {
                switch self {
                case .label1:
                    FontFamily.SFProText.regular.swiftUIFont(size: 14)
                case .label2:
                    FontFamily.SFProText.regular.swiftUIFont(size: 12)
                case .caption1:
                    FontFamily.SFProText.regular.swiftUIFont(size: 12)
                }
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
