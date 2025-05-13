// ProfilePictureAsyncJob.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Foundation
import Queues
import Vapor

/// Input payload for the profile picture job.
struct ProfilePictureJobInput: Codable {
    /// The user data transfer object.
    public let payload: UserDTO
}

/// Asynchronous job to create a profile picture.
struct ProfilePictureAsyncJob: AsyncJob {
    public typealias Payload = ProfilePictureJobInput

    /// Processes the job to create a profile picture.
    /// - Parameters:
    ///   - context: The queue context.
    ///   - payload: The input payload containing user data.
    /// - Throws: Throws an error if the profile picture creation fails.
    public func dequeue(_ context: QueueContext, _ payload: ProfilePictureJobInput) async throws {
        let logger = context.logger
        let profilePictureService = ProfilePictureService(logger: context.logger)

        // Create a profile picture for the user
        let profilePictureKey = try await profilePictureService.createProfilePicture(
            for: payload.payload
        )

        // Log the successful creation of the profile picture
        logger.info(
            "Profile picture created",
            metadata: [
                "to": .string("ProfilePictureAsyncJob.dequeue"),
                "userId": .string(payload.payload.id?.uuidString ?? ""),
                "username": .string(payload.payload.username),
                "profilePictureKey": .string(profilePictureKey),
            ]
        )
    }

    /// Handles errors that occur during the job processing.
    /// - Parameters:
    ///   - context: The queue context.
    ///   - error: The error that occurred.
    ///   - payload: The input payload containing user data.
    /// - Throws: Throws an error if logging fails.
    public func error(_ context: QueueContext, _ error: any Error, _ payload: ProfilePictureJobInput) throws {
        let logger = context.logger

        // Capture the current stack trace
        let stackTrace = Thread.callStackSymbols.joined(separator: "\n")

        // Log the error details
        logger.error(
            "Failed to create profile picture",
            metadata: [
                "to": .string("ProfilePictureAsyncJob.error"),
                "userId": .string(payload.payload.id?.uuidString ?? ""),
                "username": .string(payload.payload.username),
                "error": .string(error.localizedDescription),
                "debugInfo": .string("\(error)"),
                "stackTrace": .string(stackTrace),
            ]
        )
    }
}
