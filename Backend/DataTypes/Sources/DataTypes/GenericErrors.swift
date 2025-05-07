// GenericErrors.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

/// Represents common error cases that can occur throughout the application
/// Conforms to String, Error, Decodable, and Encodable protocols for serialization and error handling
public enum GenericErrors: String, Error, Decodable, Encodable {
    /// Error when a request is aborted
    case abortError
    /// Error related to Alamofire networking operations
    case alamofireError
    /// Error when sending a Discord webhook message fails
    case discordWebhookMessageFailed
    /// Error when response decoding fails
    case failedToDecodeResponse
    /// Error when response encoding fails
    case failedToEncodeResponse
    /// Error for invalid verification code
    case invalidCode
    /// Error for incorrectly formatted phone number
    case invalidPhoneNumber
    /// Error for invalid authentication token
    case invalidToken
    /// Error for malformed URL
    case invalidUrl
    /// Error for invalid user ID format
    case invalidUserId
    /// Error when required image is missing
    case missingImage
    /// Error for network connectivity issues
    case networkConnectivityError
    /// Error when S3 path is too short
    case s3PathTooShort
    /// Error when SMS message sending fails
    case smsMessageFailed
    /// Error when API returns neither error nor response
    case unexpectedApiStateNoErrorAndNoResponse
    /// Generic unknown error
    case unknownError
    /// Error when attempting to create user that already exists
    case userAlreadyExists
    /// Error when user cannot be found
    case userNotFound
    /// Error when verification code requests exceed rate limit
    case verificationCodeRateLimit

    /// Provides human-readable error messages for each error case
    /// - Returns: A string containing the user-friendly error message
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
            "An unknown Error has occured!"
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

/// Represents an error response structure that can be sent over the network
/// Conforms to Vapor's Content protocol for HTTP response handling
public struct ResponseError: Content {
    /// The specific error that occurred
    public let error: GenericErrors

    /// Initializes a new ResponseError
    /// - Parameter error: The GenericErrors case to be wrapped in the response
    public init(error: GenericErrors) {
        self.error = error
    }
}
