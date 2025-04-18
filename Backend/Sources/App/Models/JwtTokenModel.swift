// JwtTokenModel.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

public final class JwtTokenModel: Model, @unchecked Sendable {
    static let schema = "Jwt-Token"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "token")
    public var token: String

    @Field(key: "user_id")
    public var userId: UUID

    @Enum(key: "subject")
    public var subject: JWTTokenSubject

    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        token: String,
        userId: UUID,
        subject: JWTTokenSubject,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.token = token
        self.userId = userId
        self.subject = subject
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    public func toDTO() -> JwtTokenDTO {
        .init(
            id: id,
            token: token,
            userId: userId,
            subject: subject,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt
        )
    }

    static func fromDTO(dto: JwtTokenDTO) -> JwtTokenModel {
        JwtTokenModel(
            id: dto.id, token: dto.token, userId: dto.userId, subject: dto.subject, createdAt: dto.createdAt,
            updatedAt: dto.updatedAt, deletedAt: dto.deletedAt
        )
    }

    deinit {
        return
    }
}
