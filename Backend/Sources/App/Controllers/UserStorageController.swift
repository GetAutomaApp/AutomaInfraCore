// UserStorageController.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Vapor

struct UserStorageController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userStorageRoute = routes.grouped("user-storage")

        userStorageRoute.post("create", use: create)
        userStorageRoute.get("find", use: find)
        userStorageRoute.delete("delete", use: delete) // Delete a user storage item by id
    }

    @Sendable
    func create(req: Request) async throws -> UserStorageItemDTO {
        let dto = try req.content.decode(UserStorageItemDTO.self)

        let userId = dto.userId

        let storageItem = UserStorageItem(key: dto.key ?? "", value: dto.value ?? "", userId: userId)

        try await storageItem.save(on: req.db)

        return storageItem.toDTO()
    }

    @Sendable
    func find(req: Request) async throws -> UserStorageItemDTO {
        guard let key = req.query["key"] as String? else {
            throw Abort(.badRequest, reason: "Missing required query parameters: userId and key.")
        }

        guard let storageItem = try await UserStorageItem.query(
            on: req.dbReadOnly
        )
        .filter(\.$key == key)
        .first() else {
            throw Abort(.notFound, reason: "User storage item not found.")
        }

        return storageItem.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.query["id"] as UUID? else {
            throw Abort(.forbidden, reason: "Missing required query parameters: id.")
        }

        guard let storageItem = try await UserStorageItem.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "User storage item not found.")
        }

        try await storageItem.delete(on: req.db)

        return .noContent
    }
}
