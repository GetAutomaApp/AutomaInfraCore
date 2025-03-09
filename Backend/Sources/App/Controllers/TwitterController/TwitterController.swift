// TwitterController.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Vapor

struct TwitterController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let twitterRoute = routes.grouped("Twitter")

        twitterRoute.get("redirect", use: redirect)
    }

    @Sendable
    func redirect(req _: Request) async throws -> String {
        "Hello, World!"
    }
}
