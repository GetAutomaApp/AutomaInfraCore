// ControllerInteractor.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Alamofire
import Vapor

public protocol ControllerInteractor {
    var baseURL: String { get }
    var session: Alamofire.Session { get }

    func performRequest(
        endpoint: String,
        method: Alamofire.HTTPMethod,
        headers: Alamofire.HTTPHeaders?,
        parameters: Alamofire.Parameters?,
        encoding: ParameterEncoding
    ) async throws -> DataResponse<Data?, AFError>
}

public extension ControllerInteractor {
    var session: Alamofire.Session {
        .default
    }

    func performRequest(
        endpoint: String,
        method: Alamofire.HTTPMethod,
        headers: Alamofire.HTTPHeaders? = nil,
        parameters: Alamofire.Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default
    ) async -> DataResponse<Data?, AFError> {
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

// Data is always optional unless the decoding failed (which will also be an error)
// failedToDecodeResponse
public struct BackendControllerResponseOutput<K: Content> {
    public let data: K?
    public let error: GenericErrors?

    public init(data: K?, error: GenericErrors?) {
        self.data = data
        self.error = error
    }
}

public protocol BackendControllerInteractor: ControllerInteractor {
    func decodeResponse<K: Content>(
        _ data: DataResponse<Data?, AFError>,
        _ decodeTo: K.Type
    ) -> BackendControllerResponseOutput<K>
}

public extension BackendControllerInteractor {
    func handleResponse<K: Content>(
        response: DataResponse<Data?, AFError>,
        decodeTo: K.Type,
        rethrow: [GenericErrors]
    ) async throws -> K {
        let output = decodeResponse(
            response,
            decodeTo.self
        )

        if let error = output.error {
            if rethrow.firstIndex(of: error) != nil {
                throw error
            }
            throw GenericErrors.unknownError
        }

        guard let data = output.data else {
            throw GenericErrors.unexpectedApiStateNoErrorAndNoResponse
        }

        return data
    }

    func decodeResponse<K: Content>(
        _ data: DataResponse<Data?, AFError>,
        _ decodeTo: K.Type
    ) -> BackendControllerResponseOutput<K> {
        if let alamofireError = data.error, getErrorFromResponse(data.data) == nil {
            // TODO: Get logging into here
            if isNetworkOrConnectionError(alamofireError) {
                return .init(data: nil, error: .networkConnectivityError)
            }

            return .init(data: nil, error: .alamofireError)
        }

        // If no error, process the data
        return decodeResponse(data.data, decodeTo)
    }

    // Private methods for internal use only
    private func decodeResponse<K: Content>(
        _ data: Data?,
        _: K.Type
    ) -> BackendControllerResponseOutput<K> {
        let error = getErrorFromResponse(data)

        if let error {
            return .init(data: nil, error: error)
        }

        do {
            let value = try K.decodeJSONFromData(data: data)
            return .init(data: value, error: nil)
        } catch {
            return .init(data: nil, error: .failedToDecodeResponse)
        }
    }

    private func isNetworkOrConnectionError(_ error: Error?) -> Bool {
        guard let error = error as? URLError else { return false }

        let networkConnectionErrors = [
            URLError.timedOut,
            URLError.networkConnectionLost,
            URLError.notConnectedToInternet,
            URLError.networkConnectionLost,
            URLError.cannotFindHost,
            URLError.cannotConnectToHost,
            URLError.unsupportedURL,
            URLError.resourceUnavailable,
        ]

        return networkConnectionErrors.first(where: {
            error.code == $0
        }) != nil
    }

    private func getErrorFromResponse(
        _ data: Data?
    ) -> GenericErrors? {
        guard let data else { return nil } // Can't have error if response is empty

        let decoder = JSONDecoder()
        do {
            let value = try decoder.decode(ResponseError.self, from: data)
            return value.error
        } catch {
            return nil
        }
    }
}

public extension DataResponse {
    func statusCode() -> Int? {
        response?.statusCode
    }
}
