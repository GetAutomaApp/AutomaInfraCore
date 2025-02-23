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
    case unexpectedApiStateNoErrorAndNoResponse

    public var message: String {
        switch self {
        case .invalidCode:
            "The verification code you entered is invalid!"
        case .userAlreadyExists:
            "A user with this phone number already exists!"
        case .userNotFound:
            "Sorry, We couldn't find the user for this phone number!"
        case .invalidToken:
            "You're Authentication Token is Invalid!"
        case .invalidUserId:
            "You're UserID isn't a valid UUID. We're Investigating"
        case .discordWebhookMessageFailed:
            "Sorry, We couldn't send a message through the discord webhook"
        case .smsMessageFailed:
            "We are having some technical difficulties sending sms messages!"
        case .missingImage:
            ""
        case .failedToDecodeResponse:
            "An Invalid Response Object was sent down to the client!"
        case .failedToEncodeResponse:
            "Unfortunately we couldn't encode the response on the server side."
        case .unknownError:
            "An unknown Errors has occured!"
        case .alamofireError:
            "There was an error making the request!"
        case .networkConnectivityError:
            "Please check your internet connection. It might be offline."
        case .verificationCodeRateLimit:
            "Please wait before sending another code! You're to fast! 💨"
        case .abortError:
            "The request was aborted!"
        case .s3PathTooShort:
            "The S3 Path provided was to short."
        case .invalidUrl:
            "The URL is invalid & Couldn't be parsed!"
        case .invalidPhoneNumber:
            "The phone number provided is formatted incorrectly!"
        case .unexpectedApiStateNoErrorAndNoResponse:
            "The API route didn't send down a valid response (No Error / Response Body). Investigate!"
        }
    }
}

public struct ResponseError: Content {
    public let error: GenericErrors

    public init(error: GenericErrors) {
        self.error = error
    }
}
