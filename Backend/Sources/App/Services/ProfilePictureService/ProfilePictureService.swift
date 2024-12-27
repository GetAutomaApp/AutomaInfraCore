// ProfilePictureService.swift
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

        guard let userId = user.id?.uuidString else {
            throw AuthenticationError.invalidUserId
        }

        logger.info(
            "Generating profile picture",
            metadata: [
                "to": .string("ProfilePictureService.createProfilePicture"),
                "userId": .string(userId),
                "username": .string(user.username),
                "prompt": .string(prompt.prompt),
            ]
        )

        try messageService
            .sendDiscordWebhookAppEvent(
                input: "generating profile picture for \(userId) - \(user.username)",
                event: "\(prompt.prompt)",
                logger: logger
            )

        let images = try await openaiService.createImage(prompt).data

        guard let image = images[0].b64Json, let data = Data(base64Encoded: image) else {
            throw OpenAiErrors.missingImage
        }

        let key = "profile-picture/v1/\(user.username)-\(UUID().uuidString).jpg" // TODO: Ensure openai uses JPEG
        let bucket = try Environment.getOrThrow("TIGRIS_MEDIA_BUCKET_NAME")
        let s3Url = "s3://\(bucket)/\(key)"
        let openaiOutputs3Url = "s3://\(bucket)/openai/\(user.username)-\(UUID().uuidString).json"

        let jsonEncoder = JSONEncoder()

        _ = try await (
            tigrisService
                .put(
                    input: s3Url,
                    content: .init(data: data),
                    acl: .publicRead,
                    contentType: "image/jpeg"
                ),
            tigrisService.put(
                input: openaiOutputs3Url,
                content: .init(
                    string: jsonEncoder.encode(images).base64EncodedString()
                ),
                acl: .private,
                contentType: "application/json"
            )
        )

        let url = try tigrisService.getTigrisUrl(s3Url)

        try messageService
            .sendDiscordWebhookAppEvent(
                input: "generated profile picture for \(userId) - \(user.username)",
                event: "\(prompt.prompt)",
                imageUrl: url,
                logger: logger
            )

        logger.info(
            "Successfully generated profile picture for user",
            metadata: [
                "to": .string("ProfilePictureService.createProfilePicture"),
                "userId": .string(userId),
                "username": .string(user.username),
                "imageKey": .string(s3Url),
                "cacheKey": .string(openaiOutputs3Url),
            ]
        )

        return s3Url
    }
}
