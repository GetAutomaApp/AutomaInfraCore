// UserStorageItem.swift
// was created on 12/15/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

//
//  UserStorageItem.swift
//  Backend
//
//  Created by Simon Ferns on 12/15/24.
//
import Fluent
import struct Foundation.UUID
import Vapor

struct UserStorageItemDTO: Content {
    var id: UUID?
    var key: String?
    var value: String?
    var userId: UUID?
    var createdAt: Date?
    var updatedAt: Date?

    func toModel() -> UserStorageItem {
        let model = UserStorageItem()

        model.id = id

        if let key { model.key = key }
        if let value { model.value = value }
        if let userId { model.userId = userId }

        return model
    }
}

final class UserStorageItem: Model, @unchecked Sendable {
    static let schema = "user-storage"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "key")
    var key: String

    @Field(key: "value")
    var value: String

    @Field(key: "userId")
    var userId: UUID?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, key: String, value: String, userId: UUID?) {
        self.id = id
        self.key = key
        self.value = value
        self.userId = userId
    }

    func toDTO() -> UserStorageItemDTO {
        .init(id: id, key: key, value: value, userId: userId, createdAt: createdAt, updatedAt: updatedAt)
    }
}
