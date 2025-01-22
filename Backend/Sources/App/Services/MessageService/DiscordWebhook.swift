// DiscordWebhook.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation

struct DiscordWebhookMessage: Codable {
    var content: String?
    var username: String?
    var avatar_url: String?
    var embeds: [DiscordEmbed]?
}

struct DiscordEmbed: Codable {
    var title: String?
    var description: String?
    var url: String?
    var timestamp: String?
    var color: Int?
    var fields: [DiscordEmbedField]?
    var footer: DiscordEmbedFooter?
    var image: DiscordEmbedImage?
    var thumbnail: DiscordEmbedImage?
    var author: DiscordEmbedAuthor?
    var provider: DiscordEmbedProvider?
    var video: DiscordEmbedVideo?
}

struct DiscordEmbedField: Codable {
    var name: String
    var value: String
    var inline: Bool
}

struct DiscordEmbedFooter: Codable {
    var text: String
    var icon_url: String?
}

struct DiscordEmbedImage: Codable {
    var url: String?
}

struct DiscordEmbedAuthor: Codable {
    var name: String
    var url: String?
    var icon_url: String?
}

struct DiscordEmbedProvider: Codable {
    var name: String
    var url: String
}

struct DiscordEmbedVideo: Codable {
    var url: String
}
