// AuthenticationController.swift
// Copyright (c) 2025 GetAutomaApp
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

        authenticationRoute.get("refresh-token", use: refreshToken)
        authenticationRoute.post("login", use: login)

        let authenticatedRouteGroup = authenticationRoute.grouped(
            RequestIsAuthenticatedMiddleware()
        )

        authenticatedRouteGroup.post("logout", use: logout)
    }

    @Sendable
    func registerCode(req: Request) async throws -> AuthenticationCodeResponseDTO {
        let dto = try req.content.decode(PhoneNumberPayloadDTO.self)

        let authService = AuthenticationService(
            writeDb: req.dbWrite,
            readDb: req.dbReadOnly,
            logger: req.logger
        )

        if try await authService.doesUserExist(phoneNumber: dto.phoneNumber) {
            throw GenericErrors.userAlreadyExists
        }

        return try await authService.sendAuthCode(
            phoneNumber: dto.phoneNumber, queue: req.queue
        )
    }

    @Sendable
    func register(req: Request) async throws -> AuthenticationTokensPayloadDTO {
        let dto = try req.content.decode(AuthPhoneCodePayloadDTO.self)

        let authService = AuthenticationService(
            writeDb: req.dbWrite,
            readDb: req.dbReadOnly,
            logger: req.logger
        )

        if try await authService.doesUserExist(phoneNumber: dto.phoneNumber) {
            throw GenericErrors.userAlreadyExists
        }

        let tokens = try await authService.register(payload: dto, signer: req.jwt)

        return tokens
    }

    @Sendable
    func loginCode(req: Request) async throws -> AuthenticationCodeResponseDTO {
        let dto = try req.content.decode(PhoneNumberPayloadDTO.self)

        let authService = AuthenticationService(
            writeDb: req.dbWrite,
            readDb: req.dbReadOnly,
            logger: req.logger
        )

        if try await !(authService.doesUserExist(phoneNumber: dto.phoneNumber)) {
            throw GenericErrors.userNotFound
        }

        return try await authService.sendAuthCode(
            phoneNumber: dto.phoneNumber, queue: req.queue
        )
    }

    @Sendable
    func login(req: Request) async throws -> AuthenticationTokensPayloadDTO {
        let dto = try req.content.decode(AuthPhoneCodePayloadDTO.self)

        let authService = AuthenticationService(
            writeDb: req.dbWrite,
            readDb: req.dbReadOnly,
            logger: req.logger
        )

        let tokens = try await authService.login(payload: dto, signer: req.jwt)

        return tokens
    }

    @Sendable
    func refreshToken(req: Request) async throws -> AccessTokenPayloadDTO {
        let tokenString = try req.query.get(String?.self, at: "xxrt")

        guard let tokenString else {
            throw GenericErrors.invalidToken
        }

        let token = try await req.jwt.verify(
            tokenString,
            as: JWTTokenPayload.self
        )

        if token.subject != .refresh {
            throw GenericErrors.invalidToken
        }

        let authService = AuthenticationService(
            writeDb: req.dbWrite,
            readDb: req.dbReadOnly,
            logger: req.logger
        )

        do {
            let refreshedAccessToken = try await authService.refreshToken(
                userId: token.userId,
                signer: req.jwt
            )
            BackendMetric.totalSuccessfulTokensRefreshed.increment()
            return .init(accessToken: refreshedAccessToken)
        } catch {
            BackendMetric.totalFailedTokensRefreshed.increment()
            throw error
        }
    }

    @Sendable
    func logout(req: Request) async throws -> HTTPStatus {
        let token = try await req.jwt.verify(as: JWTTokenPayload.self)

        let userId = UUID(uuidString: token.userId)

        do {
            if let userId {
                let authService = AuthenticationService(
                    writeDb: req.dbWrite,
                    readDb: req.dbReadOnly,
                    logger: req.logger
                )

                try await authService.logout(userId: userId)
            } else {
                throw GenericErrors.invalidUserId
            }
        } catch {
            req.logger.error(
                "Failed to logout user out",
                metadata: [
                    "to": .string("AuthenticationController.logout"),
                    "error": .string("\(error.localizedDescription)"),
                ]
            )
            BackendMetric.totalFailedLogoutAttempted.increment()
            throw error
        }

        BackendMetric.totalLogoutAttempted.increment()
        return .ok
    }
}
