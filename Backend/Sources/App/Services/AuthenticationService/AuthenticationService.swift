// AuthenticationService.swift
// was created on 12/24/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import Vapor

enum AuthenticationError: Error {
    case invalidCode
}

struct AuthenticationService {
    // Add Service Methods Here
    var writeDb: Database
    var readDb: Database

    // TODO: Move this to the `Random` Service
    let nameSegments = [
        "Whimsical",
        "Girraffe",
        "Bananna",
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
        "Banana",
        "Apple",
        "Orange",
    ]

    init(writeDb: Database, readDb: Database) {
        self.writeDb = writeDb
        self.readDb = readDb
    }

    // 1. Register
    // This method will create a new User with a specific phone number
    func register(payload: AuthPhoneCodePayloadDTO) async throws -> String {
        // TODO: Validate the code
        let isCodeValid = payload.code == "whimsical-monkey"

        if !isCodeValid {
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
    func sendLoginAuthCode() throws {}

    // 3. Login
    func login() throws {}

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

        let username = "\(first)\(second)\(randomAppend)"

        return username
    }
}
