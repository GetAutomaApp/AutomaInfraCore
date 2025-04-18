// AuthenticationCodeModel.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

public final class AuthenticationCodeModel: Model, @unchecked Sendable {
    static let schema = "Authentication-Code"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "code")
    public var code: String

    @Field(key: "phone_number")
    public var phoneNumber: String

    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    public var deletedAt: Date?

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

    public func toDTO() throws -> AuthenticationCodeDTO {
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
        try AuthenticationCodeModel(
            id: dto.id, code: dto.code, phoneNumber: dto.phoneNumber, createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
            deletedAt: dto.deletedAt
        )
    }

    deinit {
        return
    }
}
