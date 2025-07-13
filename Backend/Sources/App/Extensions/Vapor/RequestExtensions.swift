// RequestExtensions.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Vapor

/// Extension on rquest to add DB aliases
public extension Request {
    /// Write DB
    var dbWrite: Database {
        db(.readOnly)
    }

    /// Read-Only DB
    var dbReadOnly: Database {
        db(.readOnly)
    }
}
