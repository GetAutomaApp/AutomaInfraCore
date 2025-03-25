// RSSFeedReaderClientError.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

enum RSSFeedReaderClientError: Error {
    case failedToReadFeed(_ error: Error)
}
