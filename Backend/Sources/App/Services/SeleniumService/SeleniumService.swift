import SwiftWebDriver
import Vapor

internal struct SeleniumService {
    public func getDriver() throws -> WebDriver<ChromeDriver> {
        let chromeOption = ChromeOptions(
            args: [
                Args(.headless)
            ]
        )

        let driver = try WebDriver(
            driver: ChromeDriver(
                driverURL: getBrowserUrl(),
                browserObject: chromeOption
            )
        )
        return driver
    }

    private func getBrowserUrl() throws -> URL {
        let browserUrlString = try Environment.getOrThrow("SELENIUM_GRID_BROWSER_URL")
        guard let browserUrl: URL = .init(string: browserUrlString) else {
            throw Abort(.internalServerError)
        }
        return browserUrl
    }
}
