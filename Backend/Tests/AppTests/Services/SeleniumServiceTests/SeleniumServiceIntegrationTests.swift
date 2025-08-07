import Testing
import Vapor

@testable import App

@Suite("SeleniumServiceIntegrationTests")
internal struct SeleniumServiceIntegrationTests {
    @Test("Get Driver")
    public func getDriver() async throws {
        try await withApp { app in
            let service = SeleniumService()
            let driver = try service.getDriver()
            let status = try await driver.status().value
            #expect(status.ready, "Driver started successfully")
        }
    }

    public func withApp(test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
}
