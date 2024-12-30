// Authentication2ControllerInteractor.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Alamofire
import DataTypes
import Foundation

// NOTE: This ControllerInteractor can be used for 3rd party apis on both the frontend + backend
// A ControllerInteractor automatically gets generated when creating a backend-controller (on client)
struct Authentication2ControllerInteractor: BackendControllerInteractor {
    let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    func makeRegisterCodeRequest(_ phoneNumber: String) async throws {
        let params = try PhoneNumberPayloadDTO(phoneNumber: phoneNumber).encodeToDictionary()

        let response = await performRequest(
            endpoint: "/Authentication/register-code",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default
        )

        let output = decodeResponse(response)

        if let error = output.error {
            switch output.error {
            case .userAlreadyExists, .invalidCode, .networkConnectivityError:
                throw error
            default:
                // TODO: Log what the actual error was here
                throw GenericErrors.unknownError
            }
        } else {
            guard response.response?.statusCode == 204 else {
                throw GenericErrors.unknownError
            }
        }
    }
}
