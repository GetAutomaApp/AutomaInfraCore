// UserModel.swift
// was created on 12/24/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

final class UserModel: Model, @unchecked Sendable {
    static let schema = "User"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "phone_number")
    var phoneNumber: String

    @Field(key: "instagram_handle")
    var instagramHandle: String?

    @Field(key: "profile_picture_key")
    var profilePictureKey: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        username: String,
        phoneNumber: String,
        instagramHandle: String? = nil,
        profilePictureKey: String? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.username = username
        self.phoneNumber = phoneNumber
        self.instagramHandle = instagramHandle
        self.profilePictureKey = profilePictureKey
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    func toDTO() -> UserDTO {
        .init(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            username: username,
            phoneNumber: phoneNumber,
            instagramHandle: instagramHandle,
            profilePictureKey: profilePictureKey
        )
    }

    static func fromDTO(dto: UserDTO) -> UserModel {
        UserModel(
            id: dto.id, username: dto.username, phoneNumber: dto.phoneNumber, instagramHandle: dto.instagramHandle,
            profilePictureKey: dto.profilePictureKey
        )
    }
}
