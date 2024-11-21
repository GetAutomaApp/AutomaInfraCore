// IconButtonComponentConfig.swift
// Simon Ferns created this file on 10/23/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

enum IconButtonVariants: String, CaseIterable {
  case generic
  case square
  case circle
  case pill
}

class IconButtonComponentConfig: ObservableObject {
  @Published var frameConfig: ButtonFrameComponentConfig = .init()
    
    @Published var variant: IconButtonVariants = .generic {
        didSet {
            applyVariantStyling()
        }
    }
  
    @Published var isDisabled: Bool = false {
        didSet {
            manageDisabledState()
        }
    }
    
  @Published var icon: DesignIconsEnum = .unknown
    
    func applyVariantStyling() {
        switch variant {
        case .generic:
            frameConfig.isCircular = false
            frameConfig.roundness = DesignTokens.defaultCornerRadius
            frameConfig.fillSpace = true
        case .square:
            frameConfig.isCircular = false
            frameConfig.roundness = DesignTokens.defaultCornerRadius
            frameConfig.fillSpace = false
            frameConfig.defaultPadding = DesignTokens.padding.buttonEven
        case .circle:
            frameConfig.isCircular = true
            frameConfig.fillSpace = false
            frameConfig.defaultPadding = DesignTokens.padding.buttonEven
        case .pill:
            frameConfig.isCircular = true
            frameConfig.fillSpace = true
            frameConfig.defaultPadding = DesignTokens.padding.button
        }
        
    }
    
    func manageDisabledState() {
        if isDisabled {
            frameConfig.frameVariant = .disabled
            return
        }
        
        frameConfig.frameVariant = .generic
    }
}
