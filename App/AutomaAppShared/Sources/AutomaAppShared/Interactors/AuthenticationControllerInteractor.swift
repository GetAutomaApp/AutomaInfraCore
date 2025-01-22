// AuthenticationControllerInteractor.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Alamofire
import DataTypes
import Foundation

// NOTE: This ControllerInteractor can be used for 3rd party apis on both the frontend + backend
// A ControllerInteractor automatically gets generated when creating a backend-controller (on client)
struct AuthenticationControllerInteractor: BackendControllerInteractor {
    let baseURL: String

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
            case .userAlreadyExists, .networkConnectivityError:
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

    func makeRegisterRequest(_ phoneNumber: String, _ code: String) async throws -> String {
        let params = try AuthPhoneCodePayloadDTO(phoneNumber: phoneNumber, code: code).encodeToDictionary()

        let response = await performRequest(
            endpoint: "/Authentication/register",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default
        )

        let output = decodeResponse(
            response,
            AuthenticationTokensPayloadDTO.self
        )

        if let error = output.error {
            switch output.error {
            case .userAlreadyExists, .invalidCode, .networkConnectivityError:
                throw error
            default:
                // TODO: Log what the actual error was here
                throw GenericErrors.unknownError
            }
        }

        guard let data = output.data else {
            throw GenericErrors.failedToDecodeResponse
        }

        return data.accessToken
    }

    func makeLoginCodeRequest(_ phoneNumber: String) async throws {
        let params = try PhoneNumberPayloadDTO(phoneNumber: phoneNumber).encodeToDictionary()

        let response = await performRequest(
            endpoint: "/Authentication/login-code",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default
        )

        let output = decodeResponse(response)

        if let error = output.error {
            switch output.error {
            case .userNotFound, .invalidCode, .networkConnectivityError:
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

    func makeLoginRequest(_ phoneNumber: String, _ code: String) async throws -> String {
        let params = try AuthPhoneCodePayloadDTO(phoneNumber: phoneNumber, code: code).encodeToDictionary()

        let response = await performRequest(
            endpoint: "/Authentication/login",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default
        )

        let output = decodeResponse(
            response,
            AuthenticationTokensPayloadDTO.self
        )

        if let error = output.error {
            switch error {
            case .userNotFound, .invalidCode, .networkConnectivityError:
                throw error
            default:
                // TODO: Log what the actual error was here
                throw GenericErrors.unknownError
            }
        }

        guard let data = output.data else {
            throw GenericErrors.failedToDecodeResponse
        }

        return data.accessToken
    }

    func makeRefreshTokenRequest(_ refreshToken: String,
                                 handleInvalidToken: @escaping () async throws -> Void) async throws
        -> AccessTokenPayloadDTO
    {
        let params = ["xxrt": refreshToken]

        let response = await performRequest(
            endpoint: "/Authentication/refresh-token",
            method: .get,
            parameters: params
        )

        let output = decodeResponse(response, AccessTokenPayloadDTO.self)

        if let error = output.error {
            switch error {
            case .invalidUserId, .userNotFound, .networkConnectivityError:
                throw error
            case .invalidToken:
                try await handleInvalidToken()
            default:
                throw GenericErrors.unknownError
            }
        }

        guard let data = output.data else {
            throw GenericErrors.failedToDecodeResponse
        }

        return data
    }
}
