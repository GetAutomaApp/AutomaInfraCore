// BackendController+KeychainAuthToken.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Alamofire
import DataTypes
import Foundation

public extension BackendControllerInteractor {
    func performRequest(
        endpoint: String,
        method: Alamofire.HTTPMethod,
        headers: Alamofire.HTTPHeaders? = nil,
        parameters: Alamofire.Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        jwt: Bool = false
    ) async -> DataResponse<Data?, AFError> {
        var headers = headers ?? Alamofire.HTTPHeaders()

        if jwt {
            if let token = await KeychainHelper.get(for: .authenticationToken) {
                headers.add(.authorization(bearerToken: token))
            } else {
                print("No authentication token found in Keychain.")
            }
        }

        let url = "\(baseURL)\(endpoint)"

        return await withCheckedContinuation { continuation in
            self.session.request(
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
}
