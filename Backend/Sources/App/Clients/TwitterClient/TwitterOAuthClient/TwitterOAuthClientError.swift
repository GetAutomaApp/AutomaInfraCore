// TwitterOAuthClientError.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import TwitterAPIKit

/// Represents errors that can occur during Twitter OAuth authentication flow
internal enum TwitterOAuthClientError: Error {
    /// Error returned from Twitter API request
    case responseError(TwitterAPIKitError)

    /// Unknown error occurred during OAuth process
    case unknown(error: ErrorOrMessage)

    /// Failed to construct the Twitter authentication URL
    case unableToMakeAuthenticateURL

    /// The OAuth token is invalid or missing required data
    case invalidOAuthToken

    /// Failed to save a token (oauth or user access tokens) to database
    case failedToSaveToken(tokenType: TwitterOAuthTokenType, error: Error)

    /// Failed to get a token (oauth or user access tokens) from database
    case failedToGetTokenFromDatabase(tokenType: TwitterOAuthTokenType, error: Error)
}

internal enum TwitterOAuthTokenType: String, Codable {
    /// The OAuth token, can be retrieved by calling `requestToken` method `TwitterOAuthCLient`
    case oauth

    /// The access tokens (access token and secret), can be retrieved by converting the oauth tokens to access tokens
    /// using the method `getUserTokens` in `TwitterOAuthClient`
    case access
}
