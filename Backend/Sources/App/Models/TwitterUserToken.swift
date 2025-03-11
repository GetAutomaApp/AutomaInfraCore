// TwitterUserToken.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

final class TwitterUserToken: Model, @unchecked Sendable {
    static let schema = "Twitter-User-Token"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "access_token")
    var accessToken: String

    @Field(key: "oauth_verifier")
    var oauthVerifier: String

    @Field(key: "secret_access_token")
    var secretAccessToken: String

    @OptionalParent(key: "auth_token_id")
    var authToken: TwitterOAuthToken?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        accessToken: String,
        secretAccessToken: String,
        oauthVerifier: String,
        authTokenID: UUID? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.accessToken = accessToken
        self.secretAccessToken = secretAccessToken
        self.oauthVerifier = oauthVerifier
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        $authToken.id = authTokenID
    }
    // func toDTO() -> TwitterOAuthTokenDTO {
    //     .init(
    //         id: id,
    //         createdAt: createdAt,
    //         updatedAt: updatedAt,
    //         deletedAt: deletedAt,
    //         oauthToken: oauthToken,
    //         oauthTokenSecret: oauthTokenSecret,
    //         oauthCallbackConfirmed: oauthCallbackConfirmed,
    //         userID: $user.id
    //     )
    // }
    //
    // static func fromDTO(_ dto: TwitterOAuthTokenDTO) -> TwitterOAuthToken {
    //     .init(
    //         id: dto.id,
    //         oauthToken: dto.oauthToken,
    //         oauthTokenSecret: dto.oauthTokenSecret,
    //         oauthCallbackConfirmed: dto.oauthCallbackConfirmed,
    //         userID: dto.userID,
    //         createdAt: dto.createdAt,
    //         updatedAt: dto.updatedAt,
    //         deletedAt: dto.deletedAt
    //     )
    // }
}
