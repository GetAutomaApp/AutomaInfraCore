import XCTest
import SwiftUI
import ViewInspector

@testable import AutomaUIKit

class OnboardingScreenTemplateComponentTests: XCTestCase {
    // one test case per method
    // one test case per completed flow (action)
    // one test case per potential edge-case
    func testIntegration() throws {
        let component = OnboardingScreenTemplateComponent()
        XCTAssertNotNil(component)
    }
}
