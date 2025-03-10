// TwitterOAuthClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Crypto
import Foundation
import Vapor

struct TwitterOAuthClient {
    let client: Client
    let logger: Logger
    let consumerKey: String
    let consumerSecret: String

    private func percentEncodeURL(_ url: String) -> String? {
        // percent encode any characters that is not in allowedCharacters
        var allowedCharacters = CharacterSet.alphanumerics
        allowedCharacters.insert(charactersIn: "-._~") // RFC 3986 unreserved characters
        return url.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }

    private func hmacSHA1Base64(signatureBaseString: String, signingKey: String) -> String {
        let keyData = Data(signingKey.utf8)
        let messageData = Data(signatureBaseString.utf8)

        // Compute HMAC-SHA1
        let hmac = HMAC<Insecure.SHA1>.authenticationCode(for: messageData, using: SymmetricKey(data: keyData))

        // Convert to Data
        let hmacData = Data(hmac)

        // Base64 encode the result
        return hmacData.base64EncodedString()
    }

    func getRequestToken() async throws -> String {
        let baseURL = "https://api.x.com/oauth/request_token"
        let method = "POST"
        print(consumerKey)
        print(consumerSecret)

        let nonce = "\(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(11))"
        let backendURL = try Environment.getOrThrow("BACKEND_URL")
        let callbackURL = "\(backendURL)/Twitter/redirect"

        var signatureParametersString = ""
        let timestamp = Int(Date().timeIntervalSince1970)
        let signatureMethod = "HMAC-SHA1"
        let oauthVersion = "1.0"

        guard
            let encodedURL = percentEncodeURL(callbackURL)
        else {
            logger.error(
                "Failed to percent encode callbacke URL.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "callbackURL": .string(callbackURL),
                ]
            )
            throw Abort(.internalServerError)
        }

        let authenticationHeaderObjectRaw = [
            "oauth_consumer_key": consumerKey,
            "oauth_signature_method": signatureMethod,
            "oauth_timestamp": "\(timestamp)",
            "oauth_nonce": nonce,
            "oauth_version": oauthVersion,
            // "oauth_callback": callbackURL,
        ].sorted { $0.key < $1.key }

        for (index, (key, value)) in authenticationHeaderObjectRaw.enumerated() {
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let encodedPair = "\(encodedKey)=\(encodedValue)"

            signatureParametersString += encodedPair

            if index == authenticationHeaderObjectRaw.count - 1 {
                let encodedCallBackURLKey = "oauth_callback"
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                signatureParametersString += "\(encodedCallBackURLKey)=\(encodedURL)"
                break
            }

            signatureParametersString += "&"
        }
        // TODO: validate signatureParametersString format is correct

        guard
            let baseURLPercentEncoded = percentEncodeURL(baseURL)
        else {
            logger.error(
                "Failed to percent encode base URL.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "baseURL": .string(baseURL),
                ]
            )
            throw Abort(.internalServerError)
        }

        // TODO: validate the format is correct
        let signatureParametersStringEncoded = signatureParametersString
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        // TODO: validate the format is correct
        let signatureBaseString = "\(method.uppercased())&\(baseURLPercentEncoded)&\(signatureParametersStringEncoded)"

        // TODO: validate the format is correct
        let percentEncodedConsumerSecret = consumerSecret
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let signingKey = "\(percentEncodedConsumerSecret)&"

        // TODO: validate the format is correct
        let signature = hmacSHA1Base64(signatureBaseString: signatureBaseString, signingKey: signingKey)

        let response = try await client.post(.init(string: baseURL)) { request in
            request.headers.add(
                name: "Authorization",
                value: "OAuth oauth_consumer_key=\"\(consumerKey)\",oauth_signature_method=\"\(signatureMethod)\",oauth_timestamp=\"\(timestamp)\",oauth_nonce=\"\(nonce)\",oauth_version=\"\(oauthVersion)\",oauth_callback=\"\(encodedURL)\",oauth_signature=\"\(signature)\""
            )
            print("Headers: \(request.headers.debugDescription)")
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
