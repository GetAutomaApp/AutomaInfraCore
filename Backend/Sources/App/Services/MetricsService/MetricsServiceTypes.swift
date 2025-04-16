// MetricsServiceTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

internal enum MetricStatus: String, Codable {
    case alreadyExists
    case fail
    case start
    case success
}
