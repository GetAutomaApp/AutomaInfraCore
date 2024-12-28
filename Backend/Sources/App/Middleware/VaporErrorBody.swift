// VaporErrorBody.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Vapor

struct ErrorStringMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        next.respond(to: request).flatMapError { error in
            let response = Response()
            response.status = .internalServerError
            response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")

            var reason: String = if let authError = error as? DataTypes.GenericErrors {
                "\(authError)"
            } else if let localizedError = error as? LocalizedError {
                localizedError.errorDescription ?? "Unknown error"
            } else {
                "Unknown error"
            }

            let jsonResponse: [String: String] = [
                "error": reason,
            ]

            do {
                response.body = try .init(data: JSONEncoder().encode(jsonResponse))
            } catch {
                response.body = .init(string: "{\"error\":true,\"reason\":\"Failed to encode error\"}")
            }

            return request.eventLoop.makeSucceededFuture(response)
        }
    }
}
