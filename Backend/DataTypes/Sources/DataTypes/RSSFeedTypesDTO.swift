// RSSFeedTypesDTO.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

struct GenericRSSFeedItem: Content {
    let title: String
    let link: String
    let description: String
    let publishDate: Date
}

struct RssFeedResponse: Content {
    let items: [GenericRSSFeedItem]
    let isRssFeed: Bool
}
