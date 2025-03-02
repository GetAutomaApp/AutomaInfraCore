// AppLaunchController.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

struct AppLaunchController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let appLaunchRoute = routes.grouped("App-Launch")

        let authenticatedRouteGroup = appLaunchRoute.grouped(
            RequestIsAuthenticatedMiddleware()
        )

        authenticatedRouteGroup.get("is-user-accepted", use: isUserAccepted)
        appLaunchRoute.get("get-client-config", use: getClientConfig)
    }

    @Sendable
    func isUserAccepted(req: Request) async throws -> UserIsAcceptedDTO {
        let token = try await req.jwt.verify(as: JWTTokenPayload.self)
        let userId = UUID(uuidString: token.userId)

        if let userId {
            let isAccepted = try await UserModel.find(userId, on: req.dbReadOnly)?.accepted ?? false
            return UserIsAcceptedDTO(accepted: isAccepted)
        } else {
            throw GenericErrors.invalidUserId
        }
    }

    @Sendable
    func getClientConfig() async throws -> AppLaunchClientConfigDTO {
        .init()
    }
}
