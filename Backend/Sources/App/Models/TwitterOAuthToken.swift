// TwitterOAuthToken.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

// public struct TwitterOAuthToken: Model {
//    public let oauthToken: String
//    public let oauthTokenSecret: String
//    public let oauthCallbackConfirmed: Bool?
// }

final class TwitterOAuthToken: Model, @unchecked Sendable {
    static let schema = "Twitter-O-Auth-Token"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "oauth_token")
    var oauthToken: String

    @Field(key: "oauth_token_secret")
    var oauthTokenSecret: String

    @OptionalBoolean(key: "oauth_callback_confirmed")
    var oauthCallbackConfirmed: Bool?

    @OptionalParent(key: "user_id")
    var user: UserModel?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        oauthToken: String,
        oauthTokenSecret: String,
        oauthCallbackConfirmed: Bool? = nil,
        userID: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.oauthToken = oauthToken
        self.oauthTokenSecret = oauthTokenSecret
        self.oauthCallbackConfirmed = oauthCallbackConfirmed
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        $user.id = userID
    }

    func toDTO() -> TwitterOAuthTokenDTO {
        .init(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            oauthToken: oauthToken,
            oauthTokenSecret: oauthTokenSecret,
            oauthCallbackConfirmed: oauthCallbackConfirmed,
            userID: $user.id
        )
    }

    static func fromDTO(_ dto: TwitterOAuthTokenDTO) -> TwitterOAuthToken {
        .init(
            id: dto.id,
            oauthToken: dto.oauthToken,
            oauthTokenSecret: dto.oauthTokenSecret,
            oauthCallbackConfirmed: dto.oauthCallbackConfirmed,
            userID: dto.userID,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
            deletedAt: dto.deletedAt
        )
    }
}
