// helpers.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

// swiftlint:disable file_name

import Vapor

public extension Environment {
    static func getOrThrow(_ key: String) throws -> String {
        guard let value = Environment.get(key) else {
            throw Abort(.notFound, reason: "Value for key \(key) not found")
        }

        return value
    }
}

public extension Task where Success == Void, Failure == any Error {
    static func detachedLogOnError(
        to: String,
        logger: Logger,
        onError: @escaping @Sendable (Error) async throws -> Void = { _ in },
        onSuccess: @escaping @Sendable () async throws -> Void = {},
        method: @escaping @Sendable () async throws -> Void
    ) {
        Task.detached {
            do {
                try await method()
            } catch {
                logger.critical(
                    "Error occurred while running detached task",
                    metadata: [
                        "to": .array([
                            .string(to),
                            .string("Task.detachedLogOnError"),
                            .string(error.localizedDescription),
                        ]),
                    ]
                )
                try await onError(error)
            }

            try await onSuccess()
        }
    }
}

public extension Data {
    func decodeAsJSON<T: Content>(type: T.Type) throws -> T {
        try JSONDecoder().decode(type.self, from: self)
    }
}

internal enum ErrorOrMessage {
    case error(Error)
    case message(String)
}
