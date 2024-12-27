// ProfilePictureService.swift
// was created on 12/26/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

struct ProfilePictureService {
    let logger: Logger

    init(logger: Logger) {
        self.logger = logger
    }

    // TODO: Feature enablement to choose one of 10 randomly generated profile pictures when openai services are down
    func createProfilePicture(for user: UserDTO) async throws -> String {
        let openaiService = try OpenAiService(logger: logger)
        let tigrisService = try TigrisService()
        let messageService = MessageService()

        let prompt = AIPromptFormatterService.createProfilePicturePrompt(
            username: user.username
        )

        if let userId = user.id?.uuidString {
            try messageService
                .sendDiscordWebhookAppEvent(
                    input: "generating profile picture for \(userId) - \(user.username)",
                    event: "\(prompt.prompt)",
                    logger: logger
                )
        }

        // TODO: All openai responses should be stored as json blobs in s3/openai/images (for
        let images = try await openaiService.createImage(prompt).data

        // TODO: Send the image to tigris
        if let image = images[0].b64Json, let data = Data(base64Encoded: image) {
            let key = "profile-picture/v1/\(user.username)-\(UUID().uuidString).jpg" // TODO: Ensure openai uses JPEG
            let bucket = try Environment.getOrThrow("TIGRIS_MEDIA_BUCKET_NAME")
            let s3Url = "s3://\(bucket)/\(key)"

            let output = try await tigrisService
                .put(
                    input: s3Url,
                    content: .init(data: data),
                    acl: .publicRead,
                    contentType: "image/jpeg"
                )

            print(output) // TODO: Turn to log

            let url = try tigrisService.getTigrisUrl(s3Url)

            if let userId = user.id?.uuidString {
                try messageService
                    .sendDiscordWebhookAppEvent(
                        input: "generated profile picture for \(userId) - \(user.username)",
                        event: "\(prompt.prompt)",
                        imageUrl: url,
                        logger: logger
                    )
            }

            print(url)

            // Log url
            return s3Url
        } else {
            // Throw Error TODO
        }

        return ""
    }
}
