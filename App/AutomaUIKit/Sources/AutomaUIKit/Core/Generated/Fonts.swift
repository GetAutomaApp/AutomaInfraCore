// Fonts.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
    import AppKit.NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
    import UIKit.UIFont
#endif
#if canImport(SwiftUI)
    import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "FontConvertible.Font", message: "This typealias will be removed in SwiftGen 7.0")
typealias Font = FontConvertible.Font

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
internal enum FontFamily {
    enum CrimsonText {
        public static let bold = FontConvertible(
            name: "CrimsonText-Bold",
            family: "Crimson Text",
            path: "CrimsonText-Bold.ttf"
        )
        public static let boldItalic = FontConvertible(
            name: "CrimsonText-BoldItalic",
            family: "Crimson Text",
            path: "CrimsonText-BoldItalic.ttf"
        )
        public static let italic = FontConvertible(
            name: "CrimsonText-Italic",
            family: "Crimson Text",
            path: "CrimsonText-Italic.ttf"
        )
        public static let regular = FontConvertible(
            name: "CrimsonText-Regular",
            family: "Crimson Text",
            path: "CrimsonText-Regular.ttf"
        )
        public static let semiBold = FontConvertible(
            name: "CrimsonText-SemiBold",
            family: "Crimson Text",
            path: "CrimsonText-SemiBold.ttf"
        )
        public static let semiBoldItalic = FontConvertible(
            name: "CrimsonText-SemiBoldItalic",
            family: "Crimson Text",
            path: "CrimsonText-SemiBoldItalic.ttf"
        )
        public static let all: [FontConvertible] = [bold, boldItalic, italic, regular, semiBold, semiBoldItalic]
    }

    enum SFProText {
        public static let bold = FontConvertible(
            name: "SFProText-Bold",
            family: "SF Pro Text",
            path: "SF-Pro-Text-Bold.otf"
        )
        public static let regular = FontConvertible(
            name: "SFProText-Regular",
            family: "SF Pro Text",
            path: "SF-Pro-Text-Regular.otf"
        )
        public static let semibold = FontConvertible(
            name: "SFProText-Semibold",
            family: "SF Pro Text",
            path: "SF-Pro-Text-Semibold.otf"
        )
        public static let all: [FontConvertible] = [bold, regular, semibold]
    }

    public static let allCustomFonts: [FontConvertible] = [CrimsonText.all, SFProText.all].flatMap(\.self)
    static func registerAllCustomFonts() {
        allCustomFonts.forEach { $0.register() }
    }
}

// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

internal struct FontConvertible {
    public let name: String
    public let family: String
    public let path: String

    #if os(macOS)
        typealias Font = NSFont
    #elseif os(iOS) || os(tvOS) || os(watchOS)
        typealias Font = UIFont
    #endif

    public func font(size: CGFloat) -> Font {
        guard let font = Font(font: self, size: size) else {
            fatalError("Unable to initialize font '\(name)' (\(family))")
        }
        return font
    }

    #if canImport(SwiftUI)
        @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
        public func swiftUIFont(size: CGFloat) -> SwiftUI.Font {
            SwiftUI.Font.custom(self, size: size)
        }

        @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
        public func swiftUIFont(fixedSize: CGFloat) -> SwiftUI.Font {
            SwiftUI.Font.custom(self, fixedSize: fixedSize)
        }

        @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
        public func swiftUIFont(size: CGFloat, relativeTo textStyle: SwiftUI.Font.TextStyle) -> SwiftUI.Font {
            SwiftUI.Font.custom(self, size: size, relativeTo: textStyle)
        }
    #endif

    public func register() {
        // swiftlint:disable:next conditional_returns_on_newline
        guard let url else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }

    fileprivate func registerIfNeeded() {
        #if os(iOS) || os(tvOS) || os(watchOS)
            if !UIFont.fontNames(forFamilyName: family).contains(name) {
                register()
            }
        #elseif os(macOS)
            if let url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
                register()
            }
        #endif
    }

    fileprivate var url: URL? {
        // swiftlint:disable:next implicit_return
        BundleToken.bundle.url(forResource: path, withExtension: nil)
    }
}

extension FontConvertible.Font {
    convenience init?(font: FontConvertible, size: CGFloat) {
        font.registerIfNeeded()
        self.init(name: font.name, size: size)
    }
}

#if canImport(SwiftUI)
    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    public extension SwiftUI.Font {
        static func custom(_ font: FontConvertible, size: CGFloat) -> SwiftUI.Font {
            font.registerIfNeeded()
            return custom(font.name, size: size)
        }
    }

    @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
    public extension SwiftUI.Font {
        static func custom(_ font: FontConvertible, fixedSize: CGFloat) -> SwiftUI.Font {
            font.registerIfNeeded()
            return custom(font.name, fixedSize: fixedSize)
        }

        static func custom(
            _ font: FontConvertible,
            size: CGFloat,
            relativeTo textStyle: SwiftUI.Font.TextStyle
        ) -> SwiftUI.Font {
            font.registerIfNeeded()
            return custom(font.name, size: size, relativeTo: textStyle)
        }
    }
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
    public static let bundle: Bundle = {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(for: BundleToken.self)
        #endif
    }()

    deinit {
        return
    }
}

// swiftlint:enable convenience_type
