import XCTest
import SwiftUI
import ViewInspector // Ensure this is added as a dependency

@testable import AutomaUIKit // Replace with your app's module name

class ButtonFrameComponentTests: XCTestCase {
    func testLabelText() throws {
        let component = ButtonFrameComponent()
        XCTAssertNotNil(component)
    }
}

