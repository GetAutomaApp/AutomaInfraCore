// Errors.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public enum GenericErrors: String, Error, Decodable, Encodable {
    case invalidCode
    case userAlreadyExists
    case userNotFound
    case invalidToken
    case invalidUserId
    case discordWebhookMessageFailed
    case smsMessageFailed
    case missingImage
    case failedToDecodeResponse
    case failedToEncodeResponse
    case unknownError
    case alamofireError
    case networkConnectivityError
    case verificationCodeRateLimit
    case abortError
    case s3PathTooShort
    case invalidUrl
    case invalidPhoneNumber
}

public struct ResponseError: Content {
    public let error: GenericErrors

    public init(error: GenericErrors) {
        self.error = error
    }
}
