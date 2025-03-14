// ScrapeRSSFeedCronJob.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Queues
import Vapor

struct ScrapeRSSFeedCronJob: AsyncScheduledJob {
    func run(context: QueueContext) async throws {
        let rssFeedService = RSSFeedService(
            database: context.dbWrite,
            client: context.application.client,
            logger: context.logger
        )

        try await rssFeedService.scrapeAndInsertLatestForAllFeeds()
    }
}
