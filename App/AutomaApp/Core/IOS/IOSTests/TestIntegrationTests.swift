import Testing

@Suite("Test Integration Tests")
struct TestIntegrationTests {
    @Test("Test Print")
    func testPrint() {
        print("Hello, World!")
    }
}