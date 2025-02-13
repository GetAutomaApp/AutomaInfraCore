// TextInputComponentComponentConfig.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

public enum TextInputComponentComponentVariants {}

public class TextInputComponentComponentConfig: TextInputFrameComponentConfig {
    @Published public var title: String
    @Published public var errorMessage: String
    @Published public var titleContentFont: IsFontTableFont
    @Published public var titleSegmentColor: Color
    @Published public var errorSegmentColor: Color

    public init(
        title: String = "",
        errorMessage: String = "",
        titleContentFont: IsFontTableFont = FontTable.SFPro.Body.body3,
        titleSegmentColor: Color = DesignTokens.colors.primaryText,
        errorSegmentColor: Color = DesignTokens.colors.error
    ) {
        self.title = title
        self.errorMessage = errorMessage
        self.titleContentFont = titleContentFont
        self.titleSegmentColor = titleSegmentColor
        self.errorSegmentColor = errorSegmentColor
    }
}
