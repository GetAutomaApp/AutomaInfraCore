// AuthenticationService.swift
// was created on 12/24/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

import AWSSNS

enum AuthenticationError: Error {
    case invalidCode
    case userAlreadyExists
    case userNotFound
}

struct AuthenticationService {
    // Add Service Methods Here
    var writeDb: Database
    var readDb: Database

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

    init(writeDb: Database, readDb: Database) {
        self.writeDb = writeDb
        self.readDb = readDb
    }

    // 1. Register
    // This method will create a new User with a specific phone number
    func register(payload: AuthPhoneCodePayloadDTO) async throws -> String {
        // TODO: Validate the code
        let isValidCode = try await AuthenticationCodeModel
            .query(on: readDb)
            .filter(\.$phoneNumber == payload.phoneNumber)
            .filter(\.$code == payload.code)
            .first() != nil

        if !isValidCode {
            throw AuthenticationError.invalidCode
        }

        let username = randomUsername()

        let userId = UUID()

        let user = UserModel(
            id: userId,
            username: username,
            phoneNumber: payload.phoneNumber
        )

        try await user.save(on: writeDb)

        // TODO: Generate JWT
        // TODO: Return JWT & Refresh Token
        return userId.uuidString
    }

    // 2. Send Login Auth Code
    // This will also be used to send the user a registeration code
    // We don't care if the user exists in this route or not
    // TODO: Integrate `Phone Number` and `Discord Webhook` Services
    func sendLoginAuthCode(phoneNumber: String) async throws -> String {
        let client = try SNSClient(region: "us-east-1")

        let code = randomCode()

        let output = try await client.publish(input: .init(
            message: "Your Automa Authentication Code is: \"\(code)\"",
            phoneNumber: phoneNumber
        ))

        let codeModel = AuthenticationCodeModel(
            id: UUID(),
            code: code,
            phoneNumber: phoneNumber,
            deletedAt: codeDeletionTime()
        )

        try await codeModel.save(on: writeDb)

        print("\(String(describing: output.messageId))")

        return code
    }

    // 3. Login
    func login(payload: AuthPhoneCodePayloadDTO) async throws -> String {
        let isValidCode = try await AuthenticationCodeModel
            .query(on: readDb)
            .filter(\.$phoneNumber == payload.phoneNumber)
            .filter(\.$code == payload.code)
            .first() != nil

        if !isValidCode {
            throw AuthenticationError.invalidCode
        }

        if try await !doesUserExist(phoneNumber: payload.phoneNumber) {
            throw AuthenticationError.userNotFound
        }

        // Get the User
        let user = try await UserModel.query(on: readDb).filter(
            \.$phoneNumber == payload.phoneNumber
        ).first()!

        // TODO: Generate JWT
        // TODO: Return JWT & Refresh Token

        return user.id!.uuidString
    }

    // 4. Refresh Token
    func refreshToken() throws {}

    // 5. Logout
    func logout() throws {}

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
}
