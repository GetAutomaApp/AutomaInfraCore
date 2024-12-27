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
        let tigrisService = try TigrisService()

        let prompt = AIPromptFormatterService.createProfilePicturePrompt(
            username: user.username
        )

        let images = try await openaiService.createImage(prompt).data

        // TODO: Send the image to tigris
        if let image = images[0].b64Json, let data = Data(base64Encoded: image) {
            let key = "profile-picture/v1/\(user.username)-\(UUID().uuidString).jpg" // TODO: Ensure openai uses JPEG
            let bucket = try Environment.getOrThrow("TIGRIS_MEDIA_BUCKET_NAME")
            let s3Url = "s3://\(bucket)/\(key)"

            let output = try await tigrisService
                .put(input: s3Url, content: .init(data: data), acl: .publicRead)

            print(output) // TODO: Turn to log

            let url = try tigrisService.getTigrisUrl(s3Url)

            return url
        } else {
            // Throw Error TODO
        }

        return ""
    }
}
