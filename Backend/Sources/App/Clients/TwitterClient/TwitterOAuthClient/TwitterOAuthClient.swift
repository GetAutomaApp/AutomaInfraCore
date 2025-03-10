// TwitterOAuthClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Crypto
import Foundation
import Vapor

struct TwitterOAuthClient {
    private let client: Client
    private let logger: Logger
    private let consumerKey: String
    private let consumerSecret: String
    private let appAPIKey: String

    func getRequestToken() async throws -> String {
        let baseURL = "https://api.x.com/oauth/request_token"
        let method = "POST"

        let nonce = "\(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(11))"
        let backendURL = try Environment.getOrThrow("BACKEND_URL")
        let callbackURL = "\(backendURL)/Twitter/redirect"

        var signatureParametersString = ""
        let timestamp = Int(Date().timeIntervalSince1970)
        let signatureMethod = "HMAC-SHA1"
        let oauthVersion = "1.0"
        let authenticationHeaderObjectRaw = [
            "oauth_consumer_key": consumerKey,
            "oauth_signature_method": signatureMethod,
            "oauth_timestamp": "\(timestamp)",
            "oauth_nonce": nonce,
            "oauth_version": oauthVersion,
            "oauth_callback": callbackURL,
        ].sorted { $0.key < $1.key }

        for (index, (key, value)) in authenticationHeaderObjectRaw.enumerated() {
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let encodedPair = "\(encodedKey)=\(encodedValue)"

            signatureParametersString += encodedPair
            if index != authenticationHeaderObjectRaw.count - 1 {
                signatureParametersString += "&"
            }
        }

        let baseURLPercentEncoded = baseURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let signatureParametersStringEncoded = signatureParametersString
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        let signatureBaseString = "\(method.uppercased())&\(baseURLPercentEncoded)&\(signatureParametersStringEncoded)"
        let signingKey = "\(consumerSecret)&"

        // use HMAC-SHA1 hashing algorithm
        let signature = HMAC<Insecure.SHA1>.authenticationCode(
            for: signatureBaseString.data(using: .utf8)!,
            using: SymmetricKey(data: signingKey.data(using: .utf8)!)
        ).withUnsafeBytes { Data($0) }.base64EncodedString()

        let response = try await client.post(.init(string: baseURL)) { request in
            request.headers.add(
                name: "Authorization",
                value: "OAuth oauth_consumer_key=\"\(consumerKey)\",oauth_signature_method=\"\(signatureMethod)\",oauth_timestamp=\"\(timestamp)\",oauth_nonce=\"\(nonce)\",oauth_version=\"\(oauthVersion)\",oauth_callback=\"\(callbackURL)\",oauth_signature=\"\(signature)\""
            )
        }
        guard
            let body = response.body
        else {
            logger.error(
                "Failed to get request token: response body empty.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "response": .string("\(response.description)"),
                ]
            )
            throw Abort(.internalServerError)
        }
        let token = String(buffer: body)
        logger.info(
            "Request token found from response.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "token": .string(token),
            ]
        )
        return token
    }
}
