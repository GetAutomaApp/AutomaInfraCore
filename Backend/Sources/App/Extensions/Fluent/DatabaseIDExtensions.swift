// DatabaseIDExtensions.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent

public extension DatabaseID {
    /// Id for primary (write / read) database
    public static let primary = DatabaseID(string: "primary")
    /// Id for the closest geographical readonly database
    public static let readOnly = DatabaseID(string: "readOnly")
}
