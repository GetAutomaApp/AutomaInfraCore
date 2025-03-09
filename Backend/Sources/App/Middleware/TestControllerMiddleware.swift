// TestControllerMiddleware.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Vapor

struct TestControllerMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let testsControllerKey = try Environment.getOrThrow("TEST_CONTROLLERS_KEY")
        guard
            let headerValue = request.headers.first(name: "X-Tests-Controller-Key")
        else {
            request.logger.error("Missing X-Tests-Controller-Key header")
            throw Abort(.unauthorized)
        }
        if headerValue != testsControllerKey {
            request.logger.error("Invalid X-Tests-Controller-Key header")
            throw Abort(.unauthorized)
        }
        return try await next.respond(to: request)
    }
}
