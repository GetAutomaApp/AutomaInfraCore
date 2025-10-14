// AutomaWebCoreClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaUtilities
import Vapor

internal struct AutomaWebCoreClient {
    private let client: any Client
    private let baseURL: URL

    public init(client: any Client) throws {
        self.client = client
        let urlString = try Environment.getOrThrow("AUTOMA_WEB_CORE_API_BASE_URL")
        baseURL = try URL.fromString(payload: .init(string: urlString))
    }

    public func getWebsiteHTML(payload: AutomaWebCoreAPIEndpointPayload) async throws -> String {
        let res = try await client.get("\(baseURL.absoluteString)/api") { req in
            try req.content.encode(payload)
        }
        return try res.content.decode(String.self)
    }
}
