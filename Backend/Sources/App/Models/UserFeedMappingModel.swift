// UserFeedMappingModel.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

final class UserFeedMappingModel: Model, @unchecked Sendable {
    static let schema = "User-Feed-Mapping"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "user_id")
    var userId: UUID

    @Field(key: "feed_id")
    var feedId: UUID

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        userId: UUID,
        feedId: UUID,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.feedId = feedId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    func toDTO() -> UserFeedMappingDTO {
        .init(
            id: id!,
            feedId: feedId,
            userId: userId,
            createdAt: createdAt!,
            updatedAt: updatedAt!,
            deletedAt: deletedAt
        )
    }

    static func fromDTO(dto: UserFeedMappingDTO) -> UserFeedMappingModel {
        let model = UserFeedMappingModel(
            id: dto.id, userId: dto.userId, feedId: dto.feedId, createdAt: dto.createdAt, updatedAt: dto.updatedAt,
            deletedAt: dto.deletedAt
        )
        return model
    }
}
