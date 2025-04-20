// TwitterAuthenticatedClientTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

/// A structure representing the response from a Twitter post request.
///
/// This struct contains the data returned by Twitter after a tweet is posted,
/// encapsulated in a `TwitterPostResponseData` object.
internal struct TwitterPostResponse: Content {
    /// The data returned by Twitter, including the tweet's text and ID.
    public let data: TwitterPostResponseData
}

/// A structure representing the data of a Twitter post response.
///
/// This struct contains the text and ID of the tweet that was posted.
internal struct TwitterPostResponseData: Content {
    /// The text content of the posted tweet.
    public let text: String

    /// The unique identifier of the posted tweet.
    public let id: String
}
