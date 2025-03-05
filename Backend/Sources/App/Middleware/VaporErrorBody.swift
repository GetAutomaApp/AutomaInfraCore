// VaporErrorBody.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Vapor

struct ErrorStringMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        next.respond(to: request).flatMapErrorThrowing { error in
            let response = Response()
            response.status = .internalServerError
            response.headers.replaceOrAdd(
                name: .contentType, value: "application/json; charset=utf-8"
            )

            let reason: DataTypes.GenericErrors =
                if let genericError = error as? DataTypes.GenericErrors {
                    genericError
                } else if error is AbortError != nil {
                    GenericErrors.abortError
                } else {
                    GenericErrors.unknownError
                }

            if reason == .abortError {
                request.logger.error(
                    "Unknown Error (Abort) occurred",
                    metadata: [
                        "to": .string("ErrorStringMiddleware.respond"),
                        "localizedDescription": .string(error.localizedDescription),
                    ]
                )
            }

            if reason == .unknownError, let localizedError = error as? LocalizedError {
                request.logger.error(
                    "Unknown Error ocurred",
                    metadata: [
                        "to": .string("ErrorStringMiddleware.respond"),
                        "localizedDescription": .string(localizedError.localizedDescription),
                        "localizedError": .string(localizedError.errorDescription ?? ""),
                        "localizedFailureReason": .string(localizedError.failureReason ?? ""),
                    ]
                )
            }

            let jsonResponse: ResponseError = .init(error: reason)

            do {
                response.body = try .init(
                    data: jsonResponse.encodeToData()
                )
            } catch {
                print(error)
                response.body = .init(
                    stringLiteral: "{\"error\":\"\(GenericErrors.failedToEncodeResponse)\"}"
                )
            }

            return response
        }
    }
}
