// AIPromptFormatterService.swift
// was created on 12/26/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import OpenAI
import Vapor

enum AIPromptFormatterService {
    // Add Service Methods Here

    static func createProfilePicturePrompt(username: String) -> ImagesQuery {
        let prompt =
            "Generate a cute, emoji-like icon in a minimalistic style with a dark background (#000000) and subtle neon green (#00FF00) accents to match the aesthetic of a sleek and modern design. Incorporate soft and rounded edges, ensuring the character or object is whimsical and playful. Use the keyword \(username) to define the main theme of the icon (e.g., Potato-Plushy, Penguin-Rainbow, Peachy-Carrot, Whimsical-Spoon, Fuzzy-Slinky). Ensure the design feels cohesive, vibrant, and adorable, with a touch of neon glow around the object for added emphasis. The background should remain simple and dark to enhance the contrast."

        let imageQuery = ImagesQuery(
            prompt: prompt,
            model: .dall_e_3,
            n: 1,
            quality: .hd,
            responseFormat: .b64_json,
            size: ._1024,
            style: .vivid
        )

        return imageQuery
    }
}
