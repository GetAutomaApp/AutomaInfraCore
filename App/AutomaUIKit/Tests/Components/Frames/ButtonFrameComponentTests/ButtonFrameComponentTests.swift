import XCTest
import SwiftUI
import ViewInspector // Ensure this is added as a dependency

@testable import AutomaUIKit // Replace with your app's module name

extension ButtonFrameComponent: Inspectable {}

class ButtonFrameComponentTests: XCTestCase {
    func testLabelText() throws {
        let component = ButtonFrameComponent()
        let view = try component.inspect().text()
        let labelText = try view.string()
        XCTAssertEqual(labelText, "Hello, ButtonFrame!")
    }

    func testStyles() throws {
        let styles = ButtonFrameComponentStyles(textColor: .red)
        let component = ButtonFrameComponent(styles: styles)
        let view = try component.inspect().text()
        XCTAssertEqual(try view.foregroundColor().color, .red)
    }
}

