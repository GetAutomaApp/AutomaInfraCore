// AuthenticationController.swift
// was created on 12/24/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

struct AuthenticationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let authenticationRoute = routes.grouped("Authentication")

        authenticationRoute.post("register", use: register)
        authenticationRoute.post("register-code", use: registerCode)

        authenticationRoute.post("login-code", use: loginCode)
        authenticationRoute.post("login", use: login)

        authenticationRoute.get("refresh-token", use: refreshToken)
    }

    @Sendable
    func registerCode(req: Request) async throws -> HTTPStatus {
        let dto = try req.content.decode(PhoneNumberPayloadDTO.self)

        let authService = AuthenticationService(
            writeDb: req.dbWrite,
            readDb: req.dbReadOnly
        )

        if try await authService.doesUserExist(phoneNumber: dto.phoneNumber) {
            throw AuthenticationError.userAlreadyExists
        }

        let code = try await authService.sendLoginAuthCode(
            phoneNumber: dto.phoneNumber
        )

        print("\(code)")

        return .noContent
    }

    @Sendable
    func register(req: Request) async throws -> AuthenticationTokensPayloadDTO {
        let dto = try req.content.decode(AuthPhoneCodePayloadDTO.self)

        let authService = AuthenticationService(
            writeDb: req.dbWrite,
            readDb: req.dbReadOnly
        )

        if try await authService.doesUserExist(phoneNumber: dto.phoneNumber) {
            throw AuthenticationError.userAlreadyExists
        }

        let tokens = try await authService.register(payload: dto, signer: req.jwt)

        return tokens
    }

    @Sendable
    func loginCode(req: Request) async throws -> HTTPStatus {
        let dto = try req.content.decode(PhoneNumberPayloadDTO.self)

        let authService = AuthenticationService(
            writeDb: req.dbWrite,
            readDb: req.dbReadOnly
        )

        if try await !(authService.doesUserExist(phoneNumber: dto.phoneNumber)) {
            throw AuthenticationError.userNotFound
        }

        let code = try await authService.sendLoginAuthCode(
            phoneNumber: dto.phoneNumber
        )

        print("\(code)")

        return .noContent
    }

    @Sendable
    func login(req: Request) async throws -> AuthenticationTokensPayloadDTO {
        let dto = try req.content.decode(AuthPhoneCodePayloadDTO.self)

        let authService = AuthenticationService(
            writeDb: req.dbWrite,
            readDb: req.dbReadOnly
        )

        let tokens = try await authService.login(payload: dto, signer: req.jwt)

        return tokens
    }

    @Sendable
    func refreshToken(req: Request) async throws -> AccessTokenPayloadDTO {
        let tokenString = try req.query.get(String?.self, at: "xxrt")

        guard let tokenString else {
            throw AuthenticationError.invalidToken
        }

        let token = try await req.jwt.verify(
            tokenString,
            as: JWTTokenPayload.self
        )

        print("\(token)")

        if token.subject != .refresh {
            throw AuthenticationError.invalidToken
        }

        let authService = AuthenticationService(
            writeDb: req.dbWrite,
            readDb: req.dbReadOnly
        )

        let refreshedAccessToken = try await authService.refreshToken(
            userId: token.userId,
            signer: req.jwt
        )

        return .init(accessToken: refreshedAccessToken)
    }
}
