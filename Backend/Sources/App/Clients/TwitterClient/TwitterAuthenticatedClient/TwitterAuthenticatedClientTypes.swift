// TwitterAuthenticatedClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

struct TwitterPostResponse: Content {
    let data: TwitterPostResponseData
}

struct TwitterPostResponseData: Content {
    let text: String
    let id: String
}
