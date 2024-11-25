import XCTest
import SwiftUI
import ViewInspector

@testable import AutomaUIKit

class InfoPairComponentTests: XCTestCase {
    // one test case per method
    // one test case per completed flow (action)
    // one test case per potential edge-case
    @MainActor func testIntegration() throws {
        let component = InfoPairComponent()
        XCTAssertNotNil(component)
    }
}
