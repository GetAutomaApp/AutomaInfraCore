// UserModel.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

public final class UserModel: Model, @unchecked Sendable {
    static let schema = "User"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "username")
    public var username: String

    @Field(key: "phone_number")
    public var phoneNumber: String

    @OptionalField(key: "instagram_handle")
    public var instagramHandle: String?

    @OptionalField(key: "profile_picture_key")
    public var profilePictureKey: String?

    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?

    @Field(key: "accepted")
    public var accepted: Bool

    init() {}

    init(
        id: UUID? = nil,
        username: String,
        phoneNumber: String,
        instagramHandle: String? = nil,
        profilePictureKey: String? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil,
        accepted: Bool
    ) {
        self.id = id
        self.username = username
        self.phoneNumber = phoneNumber
        self.instagramHandle = instagramHandle
        self.profilePictureKey = profilePictureKey
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.accepted = accepted
    }

    public func toDTO() -> UserDTO {
        let profilePictureUrl: String?
        do {
            guard let profilePictureKey else {
                // TODO: Log here as well (not as important, but good to have)
                throw URLError(.badURL)
            }

            profilePictureUrl = try TigrisService().getTigrisUrl(profilePictureKey)
        } catch {
            profilePictureUrl = nil
        }

        return .init(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            username: username,
            phoneNumber: phoneNumber,
            instagramHandle: instagramHandle,
            profilePictureKey: profilePictureKey,
            profilePictureUrl: profilePictureUrl,
            accepted: accepted
        )
    }

    static func fromDTO(dto: UserDTO) -> UserModel {
        UserModel(
            id: dto.id,
            username: dto.username,
            phoneNumber: dto.phoneNumber,
            instagramHandle: dto.instagramHandle,
            profilePictureKey: dto.profilePictureKey,
            accepted: dto.accepted
        )
    }
}
