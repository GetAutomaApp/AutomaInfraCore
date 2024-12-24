// AuthenticationControllerInteractor.swift
// was created on 12/24/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Alamofire
import Foundation

struct AuthenticationControllerInteractor {
    let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    // Private method for making generic requests using Alamofire
    private func performRequest(
        endpoint: String,
        method: HTTPMethod,
        headers: HTTPHeaders? = nil,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default
    ) async throws -> DataResponse<Data?, AFError> {
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

    /// Makes a request to /Authentication/request
    /// Change the return type to your Decodable DTO
    func makeRequest() async throws -> DataResponse<Data?, AFError> {
        try await performRequest(
            endpoint: "/Authentication/request",
            method: .get
        )
    }
}
