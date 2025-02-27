// UserIsAcceptedDTO.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

public struct UserIsAcceptedDTO: Content {
    public var accepted: Bool

    public init(accepted: Bool) {
        self.accepted = accepted
    }
}
