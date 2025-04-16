// ProfilePictureAsyncJob.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Foundation
import Queues
import Vapor

internal struct ProfilePictureJobInput: Codable {
    let payload: UserDTO
}

internal struct ProfilePictureAsyncJob: AsyncJob {
    typealias Payload = ProfilePictureJobInput

    public func dequeue(_ context: QueueContext, _ payload: ProfilePictureJobInput) async throws {
        // This is where you would run code for the job
        let logger = context.logger
        let profilePictureService = ProfilePictureService(logger: context.logger)

        let profilePictureKey = try await profilePictureService.createProfilePicture(
            for: payload.payload
        )

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

    public func error(_ context: QueueContext, _ error: any Error, _ payload: ProfilePictureJobInput) throws {
        let logger = context.logger

        let stackTrace = Thread.callStackSymbols.joined(separator: "\n") // Captures the current stack trace

        logger.error(
            "Failed to create profile picture",
            metadata: [
                "to": .string("ProfilePictureAsyncJob.error"),
                "userId": .string(payload.payload.id?.uuidString ?? ""),
                "username": .string(payload.payload.username),
                "error": .string(error.localizedDescription),
                "debugInfo": .string("\(error)"),
                "stackTrace": .string(stackTrace), // Includes the stack trace
            ]
        )
    }
}
