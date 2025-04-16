// ProfilePictureService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import OpenAI
import Vapor

internal struct ProfilePictureService {
    let logger: Logger

    public func createProfilePicture(for user: UserDTO, totalRegenerationAttempts: Int = 3,
                                     excludeText: Bool = true) async throws -> String
    {
        do {
            let tigrisService = try TigrisService()
            let messageService = MessageService()

            let query = AIPromptFormatterService.createOpenAIProfilePictureQuery(
                username: user.username
            )
            let queryString = String(reflecting: query)

            guard let userId = user.id?.uuidString else {
                throw GenericErrors.invalidUserId
            }

            logger.info(
                "Generating profile picture",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "userId": .string(userId),
                    "username": .string(user.username),
                    "query": .string(queryString),
                ]
            )

            try messageService
                .sendDiscordWebhookAppEvent(
                    input: "generating profile picture for \(userId) - \(user.username)",
                    event: queryString,
                    logger: logger
                )

            let result = try await generateImage(
                totalRegenerationAttempts: totalRegenerationAttempts,
                query: query,
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
                        content: .init(data: result.images[0]),
                        acl: .publicRead,
                        contentType: "image/jpeg"
                    ),
                tigrisService.put(
                    input: openaiOutputs3Url,
                    content: .init(
                        string: jsonEncoder.encode(result.metadataJSON).base64EncodedString()
                    ),
                    acl: .private,
                    contentType: "application/json"
                )
            )

            let url = try tigrisService.getTigrisUrl(s3Url)

            try messageService
                .sendDiscordWebhookAppEvent(
                    input: "generated profile picture for \(userId) - \(user.username)",
                    event: queryString,
                    imageUrl: url,
                    logger: logger
                )

            logger.info(
                "Successfully generated profile picture for user",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
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
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "user": .string("\(user)"),
                    "error": .string("\(error.localizedDescription)"),
                ]
            )

            BackendMetric.totalProfilePicturesGenerationFailed.increment()

            throw error
        }
    }

    private func generateImage(totalRegenerationAttempts: Int, query: GenerateImageQuery,
                               excludeText: Bool) async throws -> GenerateImageResult
    {
        let textExtractionService = TextExtractionService()
        let imageClient = ImageGenerationClient(logger: logger)

        public var hasText = false
        public var totalAttemptsLeft = totalRegenerationAttempts

        public var result: GenerateImageResult?
        // If there is still text on the image after 3 attempts, we will ignore the text and continue generating the
        // image
        repeat {
            let res = try await imageClient.generateImage(query)
            result = res

            hasText = try await !textExtractionService
                .getTextToSimpleString(
                    from: res.images[0]
                ).isEmpty

            totalAttemptsLeft -= 1
        } while excludeText && hasText && totalAttemptsLeft > 0

        guard let result else {
            throw GenericErrors.missingImage
        }

        logger.info(
            "Attempted to generate an image without text",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "totalAttempts": .string("\(totalRegenerationAttempts - totalAttemptsLeft)"),
                "hasText": .string("\(hasText)"),
            ]
        )

        return result
    }

    public func generateImageKey(for user: UserDTO) throws -> String {
        let bucket = try Environment.getOrThrow("TIGRIS_MEDIA_BUCKET_NAME")

        guard let userId = user.id?.uuidString else {
            throw GenericErrors.invalidUserId
        }

        return "s3://\(bucket)/profile-picture/v1/\(userId).jpg"
    }
}
