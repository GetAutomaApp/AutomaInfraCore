// RequestIsAuthenticatedMiddleware.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Vapor

internal struct RequestIsAuthenticatedMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let tokenPayload = try await request.jwt.verify(as: JWTTokenPayload.self)
        let messageService = MessageService()

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
                throw GenericErrors.invalidToken
            }
        } catch {
            if let error = error as? GenericErrors {
                throw error
            }

            // We want this to alert us in discord alerts + email alert (phone, email and discord automa-alerts)
            // TODO: Automa Alerts (events no noti, alerts noti)
            request.logger.critical(
                "Unknown error in Authentication Middleware",
                metadata: [
                    "to": .string("RequestIsAuthenticatedMiddleware.respond"),
                    "error": .string(error.localizedDescription),
                ]
            )

            try messageService.sendDiscordAlert(
                alertTitle: "Error in Authentication Middleware",
                error: error,
                logger: request.logger
            )

            throw error
        }
    }
}
