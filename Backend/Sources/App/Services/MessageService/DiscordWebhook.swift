// DiscordWebhook.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation

internal struct DiscordWebhookMessage: Codable {
    public var content: String?
    public var username: String?
    public var avatar_url: String?
    public var embeds: [DiscordEmbed]?
}

internal struct DiscordEmbed: Codable {
    public var title: String?
    public var description: String?
    public var url: String?
    public var timestamp: String?
    public var color: Int?
    public var fields: [DiscordEmbedField]?
    public var footer: DiscordEmbedFooter?
    public var image: DiscordEmbedImage?
    public var thumbnail: DiscordEmbedImage?
    public var author: DiscordEmbedAuthor?
    public var provider: DiscordEmbedProvider?
    public var video: DiscordEmbedVideo?
}

internal struct DiscordEmbedField: Codable {
    public var name: String
    public var value: String
    public var inline: Bool
}

internal struct DiscordEmbedFooter: Codable {
    public var text: String
    public var icon_url: String?
}

internal struct DiscordEmbedImage: Codable {
    public var url: String?
}

internal struct DiscordEmbedAuthor: Codable {
    public var name: String
    public var url: String?
    public var icon_url: String?
}

internal struct DiscordEmbedProvider: Codable {
    public var name: String
    public var url: String
}

internal struct DiscordEmbedVideo: Codable {
    public var url: String
}
