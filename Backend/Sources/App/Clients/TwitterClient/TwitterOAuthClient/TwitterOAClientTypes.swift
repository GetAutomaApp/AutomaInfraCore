// TwitterOAClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

/// A structure representing the user tokens required for Twitter OAuth authentication.
///
/// This struct contains the access token and secret access token used for authenticating
/// requests to the Twitter API.
internal struct TwitterUserTokens: Content {
    /// The access token used for Twitter API authentication.
    public let accessToken: String

    /// The secret access token used for Twitter API authentication.
    public let secretAccessToken: String
}

/// A structure representing the query parameters for Twitter OAuth redirection.
///
/// This struct encapsulates the OAuth token and verifier returned by Twitter during
/// the OAuth authentication process.
internal struct TwitterOAuthRedirectQueryParameters: Content {
    /// The OAuth token returned by Twitter.
    public let oauthToken: String

    /// The OAuth verifier returned by Twitter.
    public let oauthVerifier: String

    /// Coding keys to map the JSON keys to the struct properties.
    enum CodingKeys: String, CodingKey {
        case oauthToken = "oauth_token"
        case oauthVerifier = "oauth_verifier"
    }
}

/// A structure representing the content of a tweet to be posted.
///
/// This struct contains the message text of the tweet to be posted to Twitter.
internal struct PostTweetContent: Content {
    /// The text content of the tweet.
    public let message: String
}
