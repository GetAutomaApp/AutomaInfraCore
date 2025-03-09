// TwitterOAuthClient.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import CryptoKit
import Foundation
import Vapor

struct TwitterOAuthClient {
    private let client: Client
    private let logger: Logger
    private let consumerKey: String
    private let consumerSecret: String
    private let appAPIKey: String

    func getRequestToken() throws {
        let baseURL = "https://api.x.com/oauth/request_token"
        let method = "POST"

        let nonce = "\(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(11))"
        let callbackURL = "http://127.0.0.1:8080/Twitter/redirect"

        var request = URLRequest(
            url: URL(string: baseURL)!,
            timeoutInterval: Double.infinity
        )

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

        request.addValue(
            "OAuth oauth_consumer_key=\"\(appAPIKey)\",oauth_signature_method=\"\(signatureMethod)\",oauth_timestamp=\"\(timestamp)\",oauth_nonce=\"\(nonce)\",oauth_version=\"\(oauthVersion)\",oauth_callback=\"\(callbackURL)\",oauth_signature=\"\(signature)\"",
            forHTTPHeaderField: "Authorization"
        )

        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data else {
                print(String(describing: error))
                return
            }
            print(String(data: data, encoding: .utf8)!)
        }

        task.resume()
    }
}
