// RSSFeedItemModel.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

final class RSSFeedItemModel: Model, @unchecked Sendable {
    static let schema = "RSS-Feed-Item"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "rss_feed_id")
    var rssFeedId: UUID

    @Field(key: "content")
    var content: String

    @Field(key: "link")
    var link: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        rssFeedId: UUID,
        content: String,
        link: String,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.rssFeedId = rssFeedId
        self.content = content
        self.link = link
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    func toDTO() -> RssFeedItemDTO {
        .init(
            id: id,
            rssFeedId: rssFeedId,
            content: content,
            link: link,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt
        )
    }

    static func fromDTO(dto: RssFeedItemDTO) -> RSSFeedItemModel {
        let model = RSSFeedItemModel(
            id: dto.id, rssFeedId: dto.rssFeedId, content: dto.content, link: dto.link, createdAt: dto.createdAt,
            updatedAt: dto.updatedAt, deletedAt: dto.deletedAt
        )
        return model
    }
}
