// AuthenticationService.swift
// was created on 12/24/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Vapor

struct AuthenticationService {
    // Add Service Methods Here
    var db: Database

    init(db: Database) {
        self.db = db
    }

    // 1. Register
    // This method will create a new User with a specific phone number
    func register() throws {}

    // 2. Send Login Auth Code
    func sendLoginAuthCode() throws {}

    // 2. Login
    func login() throws {}

    // 3. Refresh Token
    func refreshToken() throws {}

    // 4. Logout
    func logout() throws {}
}
