import SwiftUI
import ViewInspector
import XCTest

@testable import AutomaUIKit

class IconButtonComponentTests: XCTestCase {
    // MARK: - Test Variant Styling Changes
    @MainActor func testVariantStylingChanges() throws {
        let config = IconButtonComponentConfig()
        
        // Test generic variant
        config.variant = .generic
        XCTAssertFalse(config.frameConfig.isCircular, "Generic variant should not be circular")
        XCTAssertEqual(config.frameConfig.roundness, DesignTokens.defaultCornerRadius, "Generic variant should have default corner radius")
        XCTAssertTrue(config.frameConfig.fillSpace, "Generic variant should fill space")
        
        // Test square variant
        config.variant = .square
        XCTAssertFalse(config.frameConfig.isCircular, "Square variant should not be circular")
        XCTAssertEqual(config.frameConfig.roundness, DesignTokens.defaultCornerRadius, "Square variant should have default corner radius")
        XCTAssertFalse(config.frameConfig.fillSpace, "Square variant should not fill space")
        XCTAssertEqual(config.frameConfig.defaultPadding, DesignTokens.padding.buttonEven, "Square variant should use buttonEven padding")
        
        // Test circle variant
        config.variant = .circle
        XCTAssertTrue(config.frameConfig.isCircular, "Circle variant should be circular")
        XCTAssertFalse(config.frameConfig.fillSpace, "Circle variant should not fill space")
        XCTAssertEqual(config.frameConfig.defaultPadding, DesignTokens.padding.buttonEven, "Circle variant should use buttonEven padding")
        
        // Test pill variant
        config.variant = .pill
        XCTAssertTrue(config.frameConfig.isCircular, "Pill variant should be circular")
        XCTAssertTrue(config.frameConfig.fillSpace, "Pill variant should fill space")
        XCTAssertEqual(config.frameConfig.defaultPadding, DesignTokens.padding.button, "Pill variant should use default button padding")
    }
    
    // MARK: - Test Disabled State Management
    @MainActor func testDisabledStateManagement() throws {
        let config = IconButtonComponentConfig()
        
        // Test enabled state
        config.isDisabled = false
        XCTAssertEqual(config.frameConfig.frameVariant, .generic, "Enabled state should have generic frame variant")
        
        // Test disabled state
        config.isDisabled = true
        XCTAssertEqual(config.frameConfig.frameVariant, .disabled, "Disabled state should have disabled frame variant")
    }
    
    // MARK: - Test Disabled State Management onTap should throw error
    @MainActor func testDisabedStateTapThrowsError() throws {
        let config = IconButtonComponentConfig()
        config.isDisabled = true
        
        let button = IconButtonComponent(
            config: config,
            action: { config in
                print(config)
            })
        
       let buttonTappable = try button.inspect().find(ViewType.Button.self)
        
        XCTAssertThrowsError(try buttonTappable.tap())
    }
    
    // MARK: - Test Initialization and Default Values
    @MainActor func testInitializationDefaults() throws {
        let config = IconButtonComponentConfig()
        
        XCTAssertEqual(config.variant, .generic, "Default variant should be generic")
        XCTAssertFalse(config.isDisabled, "Default state should be enabled")
        XCTAssertEqual(config.icon, .unknown, "Default icon should be unknown")
    }
    
    
    // MARK: - Test Multiple Buttons should modify the same config

    @MainActor func testShouldUseTheSameConfigForMultipleButtons() throws {
        let config = IconButtonComponentConfig()

        let view1 = IconButtonComponent(
            config: config,
            action: { config in
                config.isDisabled = true
            }
        )

        let view2 = IconButtonComponent(
            config: config,
            action: { config in
                config.isDisabled = false
            }
        )

        let button1 = try view1.inspect().find(ViewType.Button.self)
        try button1.tap()

        XCTAssertTrue(config.isDisabled, "The first button should update the config to disabled.")

        let button2 = try view2.inspect().find(ViewType.Button.self)

        do {
            // We expect this to throw an error
            try button2.tap()
            XCTAssertEqual(true, false, "ViewInspector .tap() should've thrown an 'unresponsive view' error.")
        } catch {
        }
    }
}
