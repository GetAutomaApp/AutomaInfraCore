// TwitterAuthenticatedClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

internal struct TwitterPostResponse: Content {
    public let data: TwitterPostResponseData
}

internal struct TwitterPostResponseData: Content {
    public let text: String
    public let id: String
}
