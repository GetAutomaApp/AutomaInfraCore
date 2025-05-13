// FirecrawlClientError.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

/// An enumeration representing errors that can occur in the FirecrawlClient.
///
/// This enum is used to define specific error cases that the FirecrawlClient might encounter
/// during its operations, such as scraping failures.
internal enum FirecrawlClientError: Error {
    /// Indicates that the scraping operation failed.
    ///
    /// This error is thrown when the FirecrawlClient is unable to successfully scrape
    /// the requested content from a website.
    case failedToScrape
}
