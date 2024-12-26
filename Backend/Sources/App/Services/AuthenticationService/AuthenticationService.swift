// AuthenticationService.swift
// was created on 12/24/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import JWT
import Vapor

struct AuthenticationService: Sendable {
    // Add Service Methods Here
    var writeDb: Database
    var readDb: Database
    var logger: Logger

    // TODO: Move this to the `Random` Service
    let nameSegments = [
        "Whimsical",
        "Giraffe",
        "Banana",
        "Monkey",
        "Penguin",
        "Elephant",
        "Cute",
        "Adorable",
        "Funny",
        "Cool",
        "Awesome",
        "Puppy",
        "Kitten",
        "Chair",
        "Dog",
        "Cat",
        "Bird",
        "Table",
        "Spoon",
        "Vegetable",
        "Fruit",
        "Animal",
        "Vehicle",
        "Potato",
        "Carrot",
        "Apple",
        "Orange",
        "Rainbow",
        "Giggle",
        "Fluffy",
        "Bouncy",
        "Ducky",
        "Zebra",
        "Cloudy",
        "Taco",
        "Pickle",
        "Snuggle",
        "Sparkle",
        "Wiggly",
        "Froggy",
        "Cupcake",
        "Bubble",
        "Biscuit",
        "Squishy",
        "Jelly",
        "Marshmallow",
        "Sprinkle",
        "Huggy",
        "Doodle",
        "Slinky",
        "Wacky",
        "Bizarre",
        "Lollipop",
        "Quirky",
        "Scooter",
        "Chuckle",
        "Cuddle",
        "Plushy",
        "Panda",
        "Moose",
        "Donkey",
        "Blossom",
        "Sunshine",
        "Snappy",
        "Jumpy",
        "Chirpy",
        "Toaster",
        "Banjo",
        "Twinkle",
        "Cheeky",
        "Peachy",
        "Fizzy",
        "Slinky",
        "Dizzy",
        "Goofy",
        "Muffin",
        "Walrus",
        "Otter",
        "Silly",
        "Candy",
        "Cup",
        "Waffle",
        "Penguin",
        "Kangaroo",
        "Smiley",
        "Lemon",
        "Fuzzy",
        "Pumpkin",
        "Popsicle",
        "Starfish",
        "Pineapple",
        "Doodlebug",
        "Cherry",
        "Mango",
        "Snickerdoodle",
        "Dandelion",
        "Hedgehog",
        "Pluto",
    ]

    init(writeDb: Database, readDb: Database, logger: Logger) {
        self.writeDb = writeDb
        self.readDb = readDb
        self.logger = logger
    }

    func getValidateAndDeleteCode(phoneNumber: String, code: String) async throws {
        logger.info(
            "Starting validation of authentication code",
            metadata: [
                "phoneNumber": .string(phoneNumber),
                "code": .string(code),
                "to": .string("AuthenticationService.getValidateAndDeleteCode"),
            ]
        )

        let validCode = try await AuthenticationCodeModel
            .query(on: readDb)
            .filter(\.$phoneNumber == phoneNumber)
            .filter(\.$code == code)
            .first()

        let isValidCode = validCode != nil
        if !isValidCode {
            logger.error(
                "Authentication code is invalid",
                metadata: [
                    "to": .string("AuthenticationService.getValidateAndDeleteCode"),
                    "code": .string(code),
                    "phoneNumber": .string(phoneNumber),
                    "validCode": .string(String(describing: validCode)),
                    "isValidCode": .string(String(describing: isValidCode)),
                ]
            )
            throw AuthenticationError.invalidCode
        }

        logger.info(
            "Authentication code is valid",
            metadata: [
                "to": .string("AuthenticationService.getValidateAndDeleteCode"),
                "code": .string(code),
                "phoneNumber": .string(phoneNumber),
                "validCode": .string(String(describing: validCode)),
                "isValidCode": .string(String(describing: isValidCode)),
            ]
        )

        sendDiscordMessage(input: phoneNumber, event: "submitted valid code `\(code)`")
        try await validCode?.delete(on: writeDb)
    }

    // 1. Register
    // This method will create a new User with a specific phone number
    func register(payload: AuthPhoneCodePayloadDTO,
                  signer: Request.JWT) async throws -> AuthenticationTokensPayloadDTO
    {
        try await getValidateAndDeleteCode(
            phoneNumber: payload.phoneNumber,
            code: payload.code
        )

        let username = randomUsername()

        let userId = UUID()

        let user = UserModel(
            id: userId,
            username: username,
            phoneNumber: payload.phoneNumber
        )

        try await user.save(on: writeDb)

        logger.info(
            "Successfully Registered User",
            metadata: [
                "to": .string("AuthenticationService.register"),
                "userId": .string(userId.uuidString),
                "username": .string(username),
            ]
        )

        sendDiscordMessage(input: "\(payload.phoneNumber) - \(userId)", event: "created an account with \(username)")

        return try await createAuthenticationTokensPayload(
            userId: userId.uuidString,
            signer: signer
        )
    }

    // 2. Send Login Auth Code
    // This will also be used to send the user a registeration code
    // We don't care if the user exists in this route or not
    func sendAuthCode(phoneNumber: String) async throws -> String {
        let messageService = MessageService()

        let code = randomCode()

        logger.info(
            "Sending verification code to user",
            metadata: [
                "to": .string("AuthenticationService.sendAuthCode"),
                "phoneNumber": .string(phoneNumber),
                "code": .string(code),
            ]
        )

        Task.detached {
            _ = try await messageService.sendSmS(
                to: phoneNumber,
                message: MessageFormatterService
                    .craftVerificationCodeMessage(code: code),
                logger: logger
            )

            let codeModelId = UUID()

            let codeModel = AuthenticationCodeModel(
                id: codeModelId,
                code: code,
                phoneNumber: phoneNumber,
                deletedAt: codeDeletionTime()
            )

            try await codeModel.save(on: writeDb)

            logger.info(
                "Sent verification code to user",
                metadata: [
                    "to": .string("AuthenticationService.sendAuthCode"),
                    "phoneNumber": .string(phoneNumber),
                    "code": .string(code),
                    "codeId": .string(codeModelId.uuidString),
                ]
            )
        }

        return code
    }

    // 3. Login
    func login(payload: AuthPhoneCodePayloadDTO, signer: Request.JWT) async throws -> AuthenticationTokensPayloadDTO {
        try await getValidateAndDeleteCode(
            phoneNumber: payload.phoneNumber,
            code: payload.code
        )

        let user = try await UserModel.query(on: readDb).filter(
            \.$phoneNumber == payload.phoneNumber
        ).first()

        if let user, let userId = user.id?.uuidString {
            sendDiscordMessage(
                input: "\(payload.phoneNumber) - \(user.username)",
                event: "logging in with code: `\(payload.code)`"
            )

            logger.info(
                "Logging in user",
                metadata: [
                    "to": .string("AuthenticationService.login"),
                    "userId": .string(userId),
                    "username": .string(user.username),
                ]
            )

            return try await createAuthenticationTokensPayload(
                userId: userId,
                signer: signer
            )
        } else {
            logger.error(
                "Can't login non-existent user",
                metadata: [
                    "to": .string("AuthenticationService.login"),
                    "phoneNumber": .string(payload.phoneNumber),
                ]
            )
            throw AuthenticationError.userNotFound
        }
    }

    // 4. Refresh Token
    func refreshToken(userId: String, signer: Request.JWT) async throws -> String {
        sendDiscordMessage(input: userId, event: "is refreshing their access token")

        logger.info(
            "Refreshing user access token",
            metadata: [
                "to": .string("AuthenticationService.refreshToken"),
                "userId": .string(userId),
            ]
        )

        return try await generateAccessToken(
            userId: userId,
            expiresIn: 86400,
            type: .access,
            signer: signer
        )
    }

    // 5. Logout
    func logout(userId: UUID) async throws {
        sendDiscordMessage(input: userId.uuidString, event: "is logging out")

        logger.info(
            "Logging user out",
            metadata: [
                "to": .string("AuthenticationService.refreshToken"),
                "userId": .string(userId.uuidString),
            ]
        )

        try await deleteOldTokens(userId: userId, subject: .refresh)
        try await deleteOldTokens(userId: userId, subject: .access)
    }

    func randomUsername() -> String {
        let first = nameSegments.randomElement()!
        var second = nameSegments.randomElement()!

        repeat {
            second = nameSegments.randomElement()!
        } while second == first

        let randomAppend = UUID().uuidString.split(separator: "-").first!.prefix(4)

        let username = "\(first)-\(second)-\(randomAppend)"

        return username
    }

    func randomCode() -> String {
        let first = nameSegments.randomElement()!.lowercased()
        let second = nameSegments.randomElement()!.lowercased()

        let code = "\(first)-\(second)"
        return code
    }

    func codeDeletionTime() -> Date {
        Date().addingTimeInterval(15 * 60)
    }

    func doesUserExist(phoneNumber: String) async throws -> Bool {
        try await UserModel.query(on: readDb).filter(\.$phoneNumber == phoneNumber).first() != nil
    }

    func generateAccessToken(
        userId: String,
        expiresIn: TimeInterval,
        type subject: JWTTokenSubject,
        signer: Request.JWT
    ) async throws -> String {
        guard let userId = UUID(uuidString: userId) else {
            throw AuthenticationError.invalidUserId
        }

        let expiresAt = Date().addingTimeInterval(expiresIn)
        let token = JWTTokenPayload(
            subject: subject,
            expiration: .init(value: expiresAt),
            userId: userId.uuidString,
            tokenId: UUID()
        )

        let signedToken = try await signer.sign(token)

        try await deleteOldTokens(userId: userId, subject: subject, skip: 5)

        let tokenId = UUID()

        try await JwtTokenModel(
            id: tokenId,
            token: signedToken,
            userId: userId,
            subject: subject,
            deletedAt: expiresAt
        ).create(on: writeDb)

        return signedToken
    }

    func deleteOldTokens(
        userId: UUID,
        subject: JWTTokenSubject,
        skip: Int? = nil
    ) async throws {
        logger.info(
            "Deleting old tokens",
            metadata: [
                "to": .string("AuthenticationService.deleteOldTokens"),
                "userId": .string(userId.uuidString),
                "subject": .string(String(describing: subject)),
                "skip": .string(String(describing: skip)),
            ]
        )

        var query = JwtTokenModel.query(on: writeDb)
            .filter(\.$userId == userId)
            .filter(\.$subject == subject)
            .sort(\.$createdAt, .descending)

        if let skip {
            query = query.range(skip...)
        }

        let tokensToDelete = try await query.all()

        for token in tokensToDelete {
            try await token.delete(on: writeDb)
            logger.info(
                "Deleted token",
                metadata: [
                    "to": .string("AuthenticationService.deleteOldTokens"),
                    "tokenId": .string(token.id?.uuidString ?? "unknown"),
                ]
            )
        }
    }

    func createAuthenticationTokensPayload(userId: String,
                                           signer: Request.JWT) async throws -> AuthenticationTokensPayloadDTO
    {
        logger.info(
            "Creating authentication tokens payload",
            metadata: [
                "to": .string("AuthenticationService.createAuthenticationTokensPayload"),
                "userId": .string(userId),
            ]
        )

        let accessToken = try await generateAccessToken(userId: userId, expiresIn: 86400, type: .access, signer: signer)
        let refreshToken = try await generateAccessToken(
            userId: userId,
            expiresIn: 31_536_000,
            type: .refresh,
            signer: signer
        )

        let tokensPayload: AuthenticationTokensPayloadDTO = .init(
            accessToken: accessToken,
            refreshToken: refreshToken
        )

        logger.info(
            "Successfully created authentication tokens payload",
            metadata: [
                "to": .string("AuthenticationService.createAuthenticationTokensPayload"),
                "userId": .string(userId),
                "accessTokenLength": .string("\(accessToken.count)"),
                "refreshTokenLength": .string("\(refreshToken.count)"),
            ]
        )

        sendDiscordMessage(
            input: userId,
            event: "generated tokens: `access: \(accessToken.count)` `refresh: \(refreshToken.count)`"
        )

        return tokensPayload
    }

    func sendDiscordMessage(
        input: String,
        event: String
    ) {
        logger.info(
            "Sending Discord message",
            metadata: [
                "to": .string("AuthenticationService.sendDiscordMessage"),
                "input": .string(input),
                "event": .string(event),
            ]
        )

        let messageService = MessageService()

        Task.detached {
            try await messageService
                .sendWebhookMessage(
                    webhookURL: URL(string: Environment.get("DISCORD_APP_EVENTS_URL")!)!,
                    message: MessageFormatterService
                        .craftUserEventDiscordWebhookMessage(
                            input: input,
                            event: event
                        ),
                    logger: logger
                )
            logger.info(
                "Successfully sent Discord message",
                metadata: [
                    "to": .string("AuthenticationService.sendDiscordMessage"),
                    "input": .string(input),
                    "event": .string(event),
                ]
            )
        }
    }
}
