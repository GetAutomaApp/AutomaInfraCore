// FeedTesterControllerInteractor.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Alamofire
import DataTypes
import Foundation

// NOTE: This ControllerInteractor can be used for 3rd party apis on both the frontend + backend
// A ControllerInteractor automatically gets generated when creating a backend-controller (on client)
struct FeedTesterControllerInteractor: BackendControllerInteractor {
    let baseURL: String

    /// Makes a request to /Feed-Tester/request
    /// Change the return type to your Decodable DTO
    func makeRequest() async throws -> DataResponse<Data?, AFError> {
        try await performRequest(
            endpoint: "/Feed-Tester/request",
            method: .get
        )
    }
}
