// AuthenticationControllerInteractor.swift
// was created on 12/20/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Alamofire
import DataTypes
import Foundation

// TODO: Error Handeling
struct AuthenticationControllerInteractor {
    let baseURL: String

    // Private method for making generic requests using Alamofire
    private func performRequest(
        endpoint: String,
        method: HTTPMethod,
        headers: HTTPHeaders? = nil,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default
    ) async -> DataResponse<Data?, AFError> {
        let url = "\(baseURL)\(endpoint)"

        // Alamofire's asynchronous request
        return await withCheckedContinuation { continuation in
            AF.request(
                url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: headers
            ).validate().response { response in
                continuation.resume(returning: response)
            }
        }
    }

    /// Makes a request to /Authentication/register-code
    /// Change the return type to your Decodable DTO
    func makeRegisterCodeRequest(_ phoneNumber: String) async throws -> String {
        let params = try PhoneNumberPayloadDTO(phoneNumber: phoneNumber).encodeToDictionary()

        let response = await performRequest(
            endpoint: "/Authentication/register-code",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default
        )

        // ensure response code is 204
        guard let statusCode = response.response?.statusCode else {
            throw AuthenticationError.excessiveRefresh
        }

        print(response)

        return ""
    }

    func makeRegisterRequest(_ phoneNumber: String, _ code: String) async throws -> String {
        let params = try AuthPhoneCodePayloadDTO(phoneNumber: phoneNumber, code: code).encodeToDictionary()

        let response = await performRequest(
            endpoint: "/Authentication/register",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default
        )

        let authTokens = try AuthenticationTokensPayloadDTO.decodeJSONFromData(
            data: response.data
        )

        return authTokens.accessToken
    }

    func makeLoginCodeRequest(_ phoneNumber: String) async throws -> String {
        let params = try PhoneNumberPayloadDTO(phoneNumber: phoneNumber).encodeToDictionary()

        let response = await performRequest(
            endpoint: "/Authentication/login-code",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default
        )

        guard let statusCode = response.response?.statusCode else {
            throw AuthenticationError.excessiveRefresh
        }

        print(response)

        return ""
    }

    func makeLoginRequest(_ phoneNumber: String, _ code: String) async throws -> String {
        let params = try AuthPhoneCodePayloadDTO(phoneNumber: phoneNumber, code: code).encodeToDictionary()

        let response = await performRequest(
            endpoint: "/Authentication/login",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default
        )

        let authTokens = try AuthenticationTokensPayloadDTO.decodeJSONFromData(
            data: response.data
        )

        return authTokens.accessToken
    }

    func makeRefreshTokenRequest(_ refreshToken: String) async throws -> AccessTokenPayloadDTO {
        let params = ["xxrt": refreshToken]

        let response = await performRequest(
            endpoint: "/Authentication/refresh-token",
            method: .get,
            parameters: params
        )

        // Default response is a string
        let authToken = try AccessTokenPayloadDTO.decodeJSONFromData(data: response.data)

        return authToken
    }
}
