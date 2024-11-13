import XCTest
import SwiftUI
import ViewInspector

@testable import AutomaUIKit

class IconButton2ComponentTests: XCTestCase {
    // one test case per method
    // one test case per completed flow (action)
    // one test case per potential edge-case
    func testIntegration() throws {
        let component = IconButton2Component()
        XCTAssertNotNil(component)
    }
}
