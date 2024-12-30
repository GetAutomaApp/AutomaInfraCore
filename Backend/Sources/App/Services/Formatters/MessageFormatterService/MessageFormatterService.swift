// MessageFormatterService.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

enum MessageFormatterService {
    static func craftVerificationCodeMessage(
        code: String
    ) -> String {
        "your automa verification code is: \"\(code)\""
    }

    static func craftUserEventDiscordWebhookMessage(input: String, event: String,
                                                    imageUrl: String? = nil) -> DiscordWebhookMessage
    {
        .init(
            embeds: [
                .init(
                    title: "**[\(input)]**",
                    description: "\(event)",
                    image: .init(url: imageUrl)
                ),
            ]
        )
    }
}
