// AppLaunchControllerInteractor.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Alamofire
import DataTypes
import Foundation

internal struct AppLaunchControllerInteractor: BackendControllerInteractor {
    let baseURL: String

    func makeIsUserAcceptedRequest() async throws -> Bool {
        let response = try await performRequest(
            endpoint: "/App-Launch/is-user-accepted",
            method: .get,
            jwt: true
        )

        let parsedResponse = try await handleResponse(
            response: response,
            decodeTo: UserIsAcceptedDTO.self,
            rethrow: [
                .networkConnectivityError,
            ]
        )

        return parsedResponse.accepted
    }

    func makeGetClientConfig() async throws -> AppLaunchClientConfigDTO {
        let response = try await performRequest(
            endpoint: "/App-Launch/get-client-config",
            method: .get
        )

        return try await handleResponse(
            response: response,
            decodeTo: AppLaunchClientConfigDTO.self,
            rethrow: [
                .networkConnectivityError,
            ]
        )
    }
}
