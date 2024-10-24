import XCTest
import SwiftUI
import ViewInspector // Ensure this is added as a dependency

@testable import YourAppModule // Replace with your app's module name

extension __CAPNAME__Component: Inspectable {}

class __CAPNAME__ComponentTests: XCTestCase {
    func testLabelText() throws {
        let component = __CAPNAME__Component()
        let view = try component.inspect().text()
        let labelText = try view.string()
        XCTAssertEqual(labelText, "Hello, __CAPNAME__!")
    }

    func testStyles() throws {
        let styles = __CAPNAME__ComponentStyles(textColor: .red)
        let component = __CAPNAME__Component(styles: styles)
        let view = try component.inspect().text()
        XCTAssertEqual(try view.foregroundColor().color, .red)
    }
}

