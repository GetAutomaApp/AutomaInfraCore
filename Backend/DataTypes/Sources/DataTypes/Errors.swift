// Errors.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

public enum GenericErrors: String, Error {
    case invalidCode
    case userAlreadyExists
    case userNotFound
    case invalidToken
    case invalidUserId
    case discordWebhookMessageFailed
    case smsMessageFailed
    case missingImage
}
