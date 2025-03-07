// RSSFeedModel.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

final class RSSFeedModel: Model, @unchecked Sendable {
    static let schema = "RSS-Feed"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "link")
    var link: URL?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        link _: URL? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    func toDTO() -> RSSFeedDTO {
        .init(
            id: id!,
            link: link!,
            createdAt: createdAt!,
            updatedAt: updatedAt!,
            deletedAt: deletedAt!
        )
    }

    static func fromDTO(dto: RSSFeedDTO) -> RSSFeedModel {
        let model = RSSFeedModel(
            id: dto.id, link: dto.link, createdAt: dto.createdAt, updatedAt: dto.updatedAt, deletedAt: dto.deletedAt
        )
        return model
    }
}
