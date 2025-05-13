// helpers.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

extension Environment {
    /// Retrieves an environment variable or throws an error if not found.
    /// - Parameter key: The key of the environment variable.
    /// - Returns: The value of the environment variable.
    /// - Throws: An error if the environment variable is not found.
    static func getOrThrow(_ key: String) throws -> String {
        guard let value = Environment.get(key) else {
            throw Abort(.notFound, reason: "Value for key \(key) not found")
        }

        return value
    }
}

extension Task where Success == Void, Failure == any Error {
    /// Executes a detached task and logs any errors that occur.
    /// - Parameters:
    ///   - destination: The destination for logging.
    ///   - logger: The logger to use for logging errors.
    ///   - onError: An optional closure to execute on error.
    ///   - onSuccess: An optional closure to execute on success.
    ///   - method: The method to execute in the task.
    static func detachedLogOnError(
        destination: String,
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
                        "destination": .array([
                            .string(destination),
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
    /// Decodes the data as JSON into a specified type.
    /// - Parameter type: The type to decode the data into.
    /// - Returns: An instance of the specified type.
    /// - Throws: An error if decoding fails.
    func decodeAsJSON<T: Content>(type: T.Type) throws -> T {
        try JSONDecoder().decode(type.self, from: self)
    }
}

/// Enum representing an error or a message.
internal enum ErrorOrMessage {
    /// Represents an error.
    case error(Error)
    /// Represents a message.
    case message(String)
}
