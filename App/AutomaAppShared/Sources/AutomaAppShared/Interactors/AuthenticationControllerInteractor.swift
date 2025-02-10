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

    func makeRegisterCodeRequest(_ phoneNumber: String) async throws -> AuthenticationCodeResponseDTO {
        let params = try PhoneNumberPayloadDTO(phoneNumber: phoneNumber).encodeToDictionary()

        let response = await performRequest(
            endpoint: "/Authentication/register-code",
            method: .post,
            parameters: params,
        )

        return try await handleResponse(
            response: response,
            decodeTo: AuthenticationCodeResponseDTO.self,
            rethrow: [
                .userAlreadyExists,
                .networkConnectivityError,
            ]
        )
    }

    func makeRegisterRequest(_ phoneNumber: String, _ code: String) async throws -> String {
        let params = try AuthPhoneCodePayloadDTO(phoneNumber: phoneNumber, code: code).encodeToDictionary()

        let response = await performRequest(
            endpoint: "/Authentication/register",
            method: .post,
            parameters: params,
        )

        return try await handleResponse(
            response: response,
            decodeTo: AuthenticationTokensPayloadDTO.self,
            rethrow: [
                .userAlreadyExists,
                .invalidCode,
                .networkConnectivityError,
            ]
        ).accessToken
    }

    func makeLoginCodeRequest(_ phoneNumber: String) async throws -> AuthenticationCodeResponseDTO {
        let params = try PhoneNumberPayloadDTO(phoneNumber: phoneNumber).encodeToDictionary()

        let response = await performRequest(
            endpoint: "/Authentication/login-code",
            method: .post,
            parameters: params,
        )

        return try await handleResponse(
            response: response,
            decodeTo: AuthenticationCodeResponseDTO.self,
            rethrow: [
                .userNotFound,
                .invalidCode,
                .networkConnectivityError,
            ]
        )
    }

    func makeLoginRequest(_ phoneNumber: String, _ code: String) async throws -> String {
        let params = try AuthPhoneCodePayloadDTO(phoneNumber: phoneNumber, code: code).encodeToDictionary()

        let response = await performRequest(
            endpoint: "/Authentication/login",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default
        )

        return try await handleResponse(
            response: response,
            decodeTo: AuthenticationTokensPayloadDTO.self,
            rethrow: [
                .userNotFound,
                .invalidCode,
                .networkConnectivityError,
            ]
        ).accessToken
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

        let data = try await handleResponse(
            response: response,
            decodeTo: AccessTokenPayloadDTO.self,
            rethrow: [
                .invalidUserId,
                .userNotFound,
                .networkConnectivityError,
            ]
        )

        let output = decodeResponse(response, AccessTokenPayloadDTO.self)
        if output.error == .invalidToken {
            try await handleInvalidToken()
        }

        return data
    }
}
