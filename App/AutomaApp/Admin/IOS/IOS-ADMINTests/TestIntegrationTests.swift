import Testing

@Suite("Test Integration Tests")
struct TestIntegrationTests {
    @Test("Test Print")
    func testPrint() {
        // Trigger Tests
        print("Hello, World!")
    }
}