import SwiftAnthropic

struct AnthropicService {
    init(apiKey: String) {
        let service = AnthropicServiceFactory.service(apiKey: apiKey)
    }
}
