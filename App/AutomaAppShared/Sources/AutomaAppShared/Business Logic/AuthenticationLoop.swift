// AuthenticationLoop.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

//
//  AuthenticationLoop.swift
//  AutomaAppShared
//
//  Created by Simon Ferns on 2/22/25.
//
import SwiftUI

struct AuthenticationLoop {
    func getAccessToken(baseUrl: String = "https://api-sandbox.getautoma.app") async {
        let authenticationController = AuthenticationControllerInteractor(baseURL: baseUrl)
        let keychain = KeychainHelper.self

        print("Access Token")
        if let refreshToken = await keychain.get(for: .RefreshToken) {
            let newAccessToken = try! await authenticationController.makeRefreshTokenRequest(
                refreshToken,
                handleInvalidToken: {
                    await keychain.delete(for: .RefreshToken)
                    await keychain.delete(for: .AuthenticationToken)
                }
            )

            await keychain
                .set(
                    for: .AuthenticationToken,
                    value: newAccessToken.accessToken
                )
        }
    }

    func startAccessTokenLoop(baseUrl: String = "https://api-sandbox.getautoma.app") async {
        Timer.scheduledTimer(withTimeInterval: 100, repeats: true) { _ in
            Task {
                await getAccessToken(baseUrl: baseUrl)
            }
        }
    }
}
