// AutomaWebCoreClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaUtilities
import Vapor

internal struct AutomaWebCoreClient {
    private let client: any Client
    private let baseURL: URL

    /// Initialize a new client for using AutomaWebCore API
    /// - Parameter client: HTTP client from a request of application
    /// - Throws: an error if environment variable `AUTOMA_WEB_CORE_API_BASE_URL` isn't found
    public init(client: any Client) throws {
        self.client = client
        let urlString = try Environment.getOrThrow("AUTOMA_WEB_CORE_API_BASE_URL")
        baseURL = try URL.fromString(payload: .init(string: urlString))
    }

    /// Get the HTML of a specific website
    /// - Parameter payload: AutomaWebCoreAPI endpoint payload for configuring what website & how to get
    /// the HTML
    /// - Throws: An error when there was a problem making a request to AutomaWebCore API or
    /// when encoding the payload into request body
    /// - Returns: The website HTML as a string
    public func getWebsiteHTML(payload: AutomaWebCoreAPIEndpointPayload) async throws -> String {
        let res = try await client.get("\(baseURL.absoluteString)/api") { req in
            try req.content.encode(payload)
        }
        do {
            return try res.content.decode(String.self)
        } catch {
            let message = try res.content.decode([String: String].self)
            throw Abort(.internalServerError, reason: message.debugDescription)
        }
    }
}
