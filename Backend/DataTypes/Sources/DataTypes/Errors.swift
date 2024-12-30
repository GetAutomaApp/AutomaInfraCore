// Errors.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

public enum GenericErrors: String, Error, Decodable {
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
}

public struct ResponseError: Encodable, Decodable {
    let error: GenericErrors

    public init(error: GenericErrors) {
        self.error = error
    }

    // Make this encodable to json object
    public func encode(to _: any Encoder) throws {}
}
