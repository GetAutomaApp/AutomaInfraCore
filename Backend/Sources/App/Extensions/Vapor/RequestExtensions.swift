// RequestExtensions.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Vapor

public extension Request {
    var dbWrite: Database {
        db(.readOnly)
    }

    var dbReadOnly: Database {
        db(.readOnly)
    }
}
