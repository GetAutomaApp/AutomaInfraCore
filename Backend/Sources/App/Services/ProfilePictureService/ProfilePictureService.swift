// ProfilePictureService.swift
// was created on 12/26/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

struct ProfilePictureService {
    func createProfilePicture(for user: UserDTO) async throws -> String {
        let openaiService = try OpenAiService()

        let prompt = AIPromptFormatterService.createProfilePicturePrompt(
            username: user.username
        )

        let images = try await openaiService.createImage(prompt).data

        // TODO: Send the image to tigris
        return images[0].b64Json ?? ""

        // TODO: Return the image url
    }
}
