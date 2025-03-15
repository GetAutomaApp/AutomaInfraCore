// AuthenticationCodeModel.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

final class AuthenticationCodeModel: Model, @unchecked Sendable {
    static let schema = "Authentication-Code"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "code")
    var code: String

    @Field(key: "phone_number")
    var phoneNumber: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        code: String,
        phoneNumber: String,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        deletedAt: Date? = nil
    ) throws {
        self.id = id
        self.code = code
        self.phoneNumber = try PhoneNumberPayloadDTO(
            number: phoneNumber
        ).phoneNumber
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    func toDTO() throws -> AuthenticationCodeDTO {
        try AuthenticationCodeDTO(
            id: id,
            phoneNumber: phoneNumber,
            code: code,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt
        )
    }

    static func fromDTO(dto: AuthenticationCodeDTO) throws -> AuthenticationCodeModel {
        let model = try AuthenticationCodeModel(
            id: dto.id, code: dto.code, phoneNumber: dto.phoneNumber, createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
            deletedAt: dto.deletedAt
        )
        return model
    }
}
