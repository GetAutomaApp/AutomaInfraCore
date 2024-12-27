// UserStorage.swift
// was created on 12/20/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

// This file will be a global struct that can be accessed anywhere which fetches variables that the clientside wants to
// use
// Getting these values will make our app way more dynamic (removing some of the constraints of only using structured
// data)

// TODO: We will create some async logic which will handle all the jwt stuff and redirect the user to the correct page if they get logged out
// FOR Now the application won't care about the security as we are setting up a very simple flow

import Alamofire
import Foundation

enum UserStorageError: Error {
    case invalidURL
    case requestFailed
    case decodingError
}

class UserStorage {
    let session = Session()

    func create(
        key: String,
        value: some Codable
    ) async throws -> UUID {
        guard let url = URL(string: "https://automa-backend-sandbox.fly.dev/user-storage/create") else {
            throw UserStorageError.invalidURL
        }

        let encodedValue = try JSONEncoder().encode(value)
        guard let valueString = String(data: encodedValue, encoding: .utf8) else {
            throw UserStorageError.decodingError
        }

        let paramsUrl = url.appending(queryItems: [
            .init(name: "key", value: key),
            .init(name: "value", value: valueString),
        ])

        let response = await session.request(paramsUrl).serializingDecodable(UUID.self).response

        switch response.result {
        case let .success(uuid):
            return uuid
        case .failure:
            throw UserStorageError.requestFailed
        }
    }
}
