// ArticleContentScraperServiceError.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

internal enum ArticleContentScraperServiceError: Error {
    case textToArticleFailed(error: Error, message: String? = nil)
}
