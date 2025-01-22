// ProfilePictureService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import OpenAI
import Vapor

struct ProfilePictureService {
    let logger: Logger

    func createProfilePicture(for user: UserDTO, totalRegenerationAttempts: Int = 3,
                              excludeText: Bool = true) async throws -> String
    {
        do {
            let tigrisService = try TigrisService()
            let messageService = MessageService()

            let prompt = AIPromptFormatterService.createOpenAIProfilePicturePrompt(
                username: user.username
            )

            guard let userId = user.id?.uuidString else {
                throw GenericErrors.invalidUserId
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

            let (images, imageData) = try await generateImage(
                totalRegenerationAttempts: totalRegenerationAttempts,
                prompt: prompt,
                excludeText: excludeText
            )

            let s3Url = try generateImageKey(for: user)

            let bucket = try Environment.getOrThrow("TIGRIS_MEDIA_BUCKET_NAME")
            let openaiOutputs3Url = "s3://\(bucket)/openai/\(user.username)-\(UUID().uuidString).json"

            let jsonEncoder = JSONEncoder()

            _ = try await (
                tigrisService
                    .put(
                        input: s3Url,
                        content: .init(data: imageData),
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
                    "tigrisUrl": .string(url),
                ]
            )

            BackendMetric.totalProfilePicturesGenerated.increment()
            return s3Url
        } catch {
            logger.error(
                "Failed to generate profile picture",
                metadata: [
                    "to": .string("ProfilePictureService.createProfilePicture"),
                    "user": .string("\(user)"),
                    "error": .string("\(error.localizedDescription)"),
                ]
            )

            BackendMetric.totalProfilePicturesGenerationFailed.increment()

            throw error
        }
    }

    private func generateImage(totalRegenerationAttempts: Int, prompt: ImagesQuery,
                               excludeText: Bool) async throws -> ([ImagesResult.Image], Data)
    {
        let textExtractionService = TextExtractionService()
        let openaiService = try OpenAiService(logger: logger)

        var hasText = false
        var image: String?
        var imageData: Data?
        var images: [ImagesResult.Image] = []
        var totalAttemptsLeft = totalRegenerationAttempts

        // If there is still text on the image after 3 attempts, we will ignore the text and continue generating the
        // image
        repeat {
            images = try await openaiService.createImage(prompt).data
            image = images[0].b64Json

            guard let image else { throw GenericErrors.missingImage }

            imageData = Data(base64Encoded: image)

            guard let imageData else { throw GenericErrors.missingImage }

            hasText = try await !textExtractionService
                .getTextToSimpleString(
                    from: imageData
                ).isEmpty

            totalAttemptsLeft -= 1
        } while excludeText && hasText && totalAttemptsLeft > 0

        logger.info(
            "Attempted to generate an image without text",
            metadata: [
                "to": .string("ProfilePictureService.generateImage"),
                "totalAttempts": .string("\(totalRegenerationAttempts - totalAttemptsLeft)"),
                "hasText": .string("\(hasText)"),
            ]
        )

        guard let imageData else {
            throw GenericErrors.missingImage
        }

        return (images, imageData)
    }

    func generateImageKey(for user: UserDTO) throws -> String {
        let bucket = try Environment.getOrThrow("TIGRIS_MEDIA_BUCKET_NAME")

        guard let userId = user.id?.uuidString else {
            throw GenericErrors.invalidUserId
        }

        return "s3://\(bucket)/profile-picture/v1/\(userId).jpg"
    }
}
