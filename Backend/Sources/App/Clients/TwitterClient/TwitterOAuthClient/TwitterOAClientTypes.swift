// TwitterOAClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

internal struct TwitterUserTokens: Content {
    public let accessToken: String
    public let secretAccessToken: String
}

internal struct TwitterOAuthRedirectQueryParameters: Content {
    public let oauthToken: String
    public let oauthVerifier: String

    enum CodingKeys: String, CodingKey {
        case oauthToken = "oauth_token"
        case oauthVerifier = "oauth_verifier"
    }
}

internal struct PostTweetContent: Content {
    public let message: String
}
