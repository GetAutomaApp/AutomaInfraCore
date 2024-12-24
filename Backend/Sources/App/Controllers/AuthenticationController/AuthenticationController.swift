// AuthenticationController.swift
// was created on 12/24/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Vapor

struct AuthenticationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let authenticationRoute = routes.grouped("Authentication")

//        authenticationRoute.get("request", use: request)
    }
}
