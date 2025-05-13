// TwitterAuthenticatedClientError.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import TwitterAPIKit

/// Errors that can occur when making authenticated requests to the Twitter API
internal enum TwitterAuthenticatedClientError: Error {
    /// The Twitter API response was empty or nil when data was expected
    case responseEmpty

    /// An error occurred while processing the Twitter API response
    /// - Parameter error: The underlying TwitterAPIKit error
    case responseError(TwitterAPIKitError)
}
