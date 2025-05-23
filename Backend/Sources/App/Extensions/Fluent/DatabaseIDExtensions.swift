// DatabaseIDExtensions.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

public extension DatabaseID {
    static let primary = DatabaseID(string: "primary")
    static let readOnly = DatabaseID(string: "readOnly")
}
