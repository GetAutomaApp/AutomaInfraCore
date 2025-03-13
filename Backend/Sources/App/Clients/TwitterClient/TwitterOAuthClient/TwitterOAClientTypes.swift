// TwitterOAClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

struct TwitterUserTokens: Content {
    let accessToken: String
    let secretAccessToken: String
}

struct TwitterOAuthRedirectQueryParameters: Content {
    let oauthToken: String
    let oauthVerifier: String

    enum CodingKeys: String, CodingKey {
        case oauthToken = "oauth_token"
        case oauthVerifier = "oauth_verifier"
    }
}
