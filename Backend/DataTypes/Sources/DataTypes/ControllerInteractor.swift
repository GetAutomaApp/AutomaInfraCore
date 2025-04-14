// ControllerInteractor.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Alamofire
import Vapor

/// Protocol used on the client and integration tests to call endpoints for a controller
/// (collection of routes)
public protocol ControllerInteractor {
    /// Server base url
    var baseURL: String { get }

    /// Alamofire request session
    var session: Alamofire.Session { get }

    /// Make a request to a specific endpoint and get the Alamofire response object
    /// - Parameters:
    ///   - endpoint: Controller route endpoint
    ///   - method: Request method (get, post, etc)
    ///   - headers: Headers to pass with the request
    ///   - parameters: Parameters to pass with the request
    ///   - encoding: Encoding method
    ///
    /// - Throws: An error with making the request
    /// - Returns: Alamofire response object, including data and error
    func performRequest(
        endpoint: String,
        method: Alamofire.HTTPMethod,
        headers: Alamofire.HTTPHeaders?,
        parameters: Alamofire.Parameters?,
        encoding: ParameterEncoding
    ) async throws -> DataResponse<Data?, AFError>
}

/// Create default implementations of functions in protocol, including `performRequest`
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

/// Optional data and error for the response of calling an endpoint
/// in a controller from the backend
/// Data is always optional unless the decoding failed (which will also be an error)
public struct BackendControllerResponseOutput<K: Content> {
    /// Optional data, conforming to `Content`; this is the response content
    public let data: K?

    /// Optional error, an occurred with getting the response
    public let error: GenericErrors?

    /// Create a new `BackendControllerResponseOutput` instance
    /// - Parameters:
    ///   - data: Optional data; the response content
    ///   - error: Optional error; an error that occurred in getting the response
    ///
    public init(data: K?, error: GenericErrors?) {
        self.data = data
        self.error = error
    }
}

/// Protocol specifically to interact with backend controllers on the client
public protocol BackendControllerInteractor: ControllerInteractor {
    /// Decode response from network request to expected `Content` data type
    /// - Parameters:
    ///   - data: Data response, containing optional data on success and error on failure
    ///   - decodeTo: expected `Content` data type
    ///
    /// - Returns: `BackendControllerResponseOutput`, containing optional error and data
    func decodeResponse<K: Content>(
        _ data: DataResponse<Data?, AFError>,
        _ decodeTo: K.Type
    ) -> BackendControllerResponseOutput<K>
}

/// Implement `decodeResponse` and `handleResponse` function
public extension BackendControllerInteractor {
    /// Get the expected response `Content` data type, or throw an error
    /// Use this function to get the content object of a response
    /// - Parameters:
    ///   - response: Data response, containing optional data on success and error on failure
    ///   - decodeTo: expected `Content` data type
    ///   - rethrow: an array of errors to directly throw if the error is one of them, else throw an unknown error
    ///
    /// - Throws: `GenericErrors`
    /// - Returns: `K`, a `Content` object; the response data
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
            print("Error checking if user exists: \(error.localizedDescription)")

            // Loop over errors and check if error is one of the errors to throw directly
            try rethrow.forEach { rethrowError in
                if rethrowError == error {
                    throw error
                }
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

    /// Decode response into `BackendControllerResponseOutput`,
    /// an object with the content and error
    /// - Parameters:
    ///   - data: Optional data to be decoded
    ///   - K: The expected response data type
    /// - Returns: `BackendControllerResponseOutput`
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

    /// Function that checks if a specific error is either a connection or network error.
    /// - Parameter error: Optional error to be checked
    /// - Returns: Bool, true if the error is a connection or network error
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

    /// Get error from a network request response data
    /// - Parameter data: Optional response data
    /// - Returns: Optional `GenericErrors`
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

/// Get the status code more easily from a `DataResponse`
public extension DataResponse {
    /// Function to get the response status code
    /// - Returns: The status code, an optional integer
    func statusCode() -> Int? {
        response?.statusCode
    }
}
