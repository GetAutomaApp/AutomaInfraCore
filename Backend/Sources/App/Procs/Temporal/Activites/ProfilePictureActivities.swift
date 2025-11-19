// ProfilePictureActivities.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Foundation
import Temporal
import Vapor

internal struct CreateProfilePictureActivityInput {
    let logger: Logger
    let payload: CreateProfilePictureActivityPayload
}

/// Input payload for the create profile picture activity.
internal struct CreateProfilePictureActivityPayload: Codable {
    /// The user data transfer object.
    public let payload: UserDTO
}

/// Temporal activity for user profile picture creation.
@ActivityContainer
internal struct ProfilePictureActivities {
    /// Create
    /// - Parameters:
    ///   - payload: The input payload containing user data.
    /// - Throws: Throws an error if the profile picture creation fails.
    @Activity
    public func createPicture(input: CreateProfilePictureActivityInput) async throws {
        let innerPayload = input.payload.payload
        let logger = input.logger
        let profilePictureService = ProfilePictureService(logger: logger)

        do {
            // Create a profile picture for the user
            let profilePictureKey = try await profilePictureService.createProfilePicture(
                for: innerPayload
            )
            // Log the successful creation of the profile picture
            logger.info(
                "Profile picture created",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "userId": .string(innerPayload.id?.uuidString ?? ""),
                    "username": .string(innerPayload.username),
                    "profilePictureKey": .string(profilePictureKey),
                ]
            )
        } catch {
            // Capture the current stack trace
            let stackTrace = Thread.callStackSymbols.joined(separator: "\n")

            // Log the error details
            logger.error(
                "Failed to create profile picture",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "userId": .string(innerPayload.id?.uuidString ?? ""),
                    "username": .string(innerPayload.username),
                    "error": .string(error.localizedDescription),
                    "stackTrace": .string(stackTrace),
                ]
            )
        }
    }
}
