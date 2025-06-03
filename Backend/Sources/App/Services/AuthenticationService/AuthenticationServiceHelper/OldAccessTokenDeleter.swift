// OldAccessTokenDeleter.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import JWT
import Queues
import Vapor

internal struct OldAccessTokenDeleter {
    let config: OldAccessTokenDeleterConfig

    init(_ config: OldAccessTokenDeleterConfig) {
        self.config = config
    }

    public func deleteOldTokens() async throws {
        logDeleteOldTokensStart()
        try await deleteTokens(getTokensToDelete())
    }

    private func logDeleteOldTokensStart() {
        config.logger.info(
            "Deleting old tokens",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "userId": .string(config.payload.userId.uuidString),
                "subject": .string(String(reflecting: config.payload.subject)),
                "skip": .string(String(reflecting: config.payload.totalNewestTokensToSkip)),
            ]
        )
    }

    private func getTokensToDelete() async throws -> [JwtTokenModel] {
        try await getQueryForTokensToDelete().all()
    }

    private func getQueryForTokensToDelete() -> QueryBuilder<JwtTokenModel> {
        var query = getQueryForAllTokensInDescendingOrder()
        if let totalNewestTokensToSkip = config.payload.totalNewestTokensToSkip {
            query = skipSomeNewestTokens(amount: totalNewestTokensToSkip, fromQuery: query)
        }
        return query
    }

    private func getQueryForAllTokensInDescendingOrder() -> QueryBuilder<JwtTokenModel> {
        JwtTokenModel.query(on: config.writeDb)
            .filter(\.$userId == config.payload.userId)
            .filter(\.$subject == config.payload.subject)
            .sort(\.$createdAt, .descending)
    }

    private func skipSomeNewestTokens(
        amount: Int,
        fromQuery query: QueryBuilder<JwtTokenModel>
    ) -> QueryBuilder<JwtTokenModel> {
        query.range(amount...)
    }

    private func deleteTokens(_ tokens: [JwtTokenModel]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for token in tokens {
                group.addTask {
                    try await deleteToken(token)
                }
            }

            try await group.waitForAll()
        }
    }

    private func deleteToken(_ token: JwtTokenModel) async throws {
        try await token.delete(on: config.writeDb)
        try logDeleteTokenSuccess(id: token.requireID())
    }

    private func logDeleteTokenSuccess(id: UUID) {
        config.logger.info(
            "Deleted token",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "tokenId": .string(id.uuidString)
            ]
        )
    }
}

internal struct OldAccessTokenDeleterConfig: AuthenticationServiceConfig {
    let writeDb: Database
    let readDb: Database
    let logger: Logger
    let payload: DeleteOldAccessTokensPayload
}

internal struct DeleteOldAccessTokensPayload {
    let userId: UUID
    let subject: JWTTokenSubject
    let totalNewestTokensToSkip: Int?

    init(
        userId: UUID,
        subject: JWTTokenSubject,
        totalNewestTokensToSkip: Int? = nil
    ) {
        self.userId = userId
        self.subject = subject
        self.totalNewestTokensToSkip = totalNewestTokensToSkip
    }
}
