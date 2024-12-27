// AuthenticationControllerInteractorIntegrationTests.swift
// was created on 12/27/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

@testable import AutomaAppShared
import Testing

// TODO: Proper testing for this (and rename struct)
// TODO: Test bad scenarios / failures (ensure we throw typesafe errors)
struct Test {
    @Test func testRequestCodeInteraction() async throws {
        let interactor =
            AuthenticationControllerInteractor(baseURL: "http://localhost:8080") // TODO: Write Controller Interactor Tests from this file as template + env var the 8080 for integraion tests, mock alamofire for unit)

        let response = try await interactor.makeRegisterCodeRequest("+27791931251")

        print(response)
    }

    @Test func testRegisterInteraction() async throws {
        let interactor =
            AuthenticationControllerInteractor(baseURL: "http://localhost:8080") // TODO: Write Controller Interactor Tests from this file as template + env var the 8080 for integraion tests, mock alamofire for unit)
        let response = try await interactor
            .makeRegisterRequest("+27791931251",
                                 "hedgehog-cheeky") // TODO: Add default testing creds so that running API accepts +000000000 as the user to run all tests on (or most of the tests requiring user)

        print(response)
        #expect(response.count > 250)
    }

    @Test func testLoginCodeInteraction() async throws {
        let interactor =
            AuthenticationControllerInteractor(baseURL: "http://localhost:8080") // TODO: Write Controller Interactor Tests from this file as template + env var the 8080 for integraion tests, mock alamofire for unit)

        let response = try await interactor.makeRegisterCodeRequest("+27791931251")

        print(response)
    }

    @Test func testLoginInteraction() async throws {
        let interactor =
            AuthenticationControllerInteractor(baseURL: "http://localhost:8080") // TODO: Write Controller Interactor Tests from this file as template + env var the 8080 for integraion tests, mock alamofire for unit)
        let response = try await interactor
            .makeRegisterRequest("+27791931251",
                                 "hedgehog-cheeky") // TODO: Add default testing creds so that running API accepts +000000000 as the user to run all tests on (or most of the tests requiring user)

        print(response)
        #expect(response.count > 250)
    }

    @Test func testRefreshTokenInteraction() async throws {
        let interactor =
            AuthenticationControllerInteractor(baseURL: "http://localhost:8080") // TODO: Write Controller Interactor Tests from this file as template + env var the 8080 for integraion tests, mock alamofire for unit)

        let response = try await interactor
            .makeRefreshTokenRequest(
                "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NjY4NTI2OTguMDkyMzIyOCwidGlkIjoiRkVDMDYwMEYtMjNCNi00NEMwLUJDRUMtMjcwNTEwMTRFMUQ1IiwidWlkIjoiQTIwRUY4MUEtQkQxOC00QkVFLUFBOUMtQTczRERBODcyNDdGIiwic3ViIjoicmVmcmVzaCJ9.elZ22K55u-Qy6WesvPVvi2DVPKf2PisJbHNPIAUbW3k"
            )

        print(response)
        #expect(response.accessToken.count > 250)
    }
}
