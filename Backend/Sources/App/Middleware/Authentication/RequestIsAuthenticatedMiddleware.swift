// RequestIsAuthenticatedMiddleware.swift
// was created on 12/26/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Vapor

struct RequestIsAuthenticatedMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let tokenPayload = try await request.jwt.verify(as: JWTTokenPayload.self)

        do {
            let token = try await JwtTokenModel.find(
                tokenPayload.tokenId,
                on: request.dbReadOnly
            )

            if token != nil {
                return try await next.respond(to: request)
            } else {
                request.logger.error(
                    "User Token is invalid",
                    metadata: [
                        "to": .string("RequestIsAuthenticatedMiddleware.respond"),
                        "token": .string(
                            request.headers.bearerAuthorization?.token ?? ""
                        ),
                    ]
                )
                throw AuthenticationError.invalidToken
            }
        } catch {
            if let error = error as? AuthenticationError {
                throw error
            }

            // We want this to alert us in discord alerts + email alert (phone, email and discord automa-alerts)
            // TODO: Automa Alerts (events no noti, alerts noti)
            request.logger.trace(
                "Unknown error in Authentication Middleware",
                metadata: [
                    "to": .string("RequestIsAuthenticatedMiddleware.respond"),
                    "error": .string(error.localizedDescription),
                ]
            )
            throw error
        }
    }
}
