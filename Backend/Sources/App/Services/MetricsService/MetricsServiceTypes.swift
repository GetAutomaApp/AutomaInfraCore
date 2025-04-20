// MetricsServiceTypes.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

/// Enum representing the status of a metric.
internal enum MetricStatus: String, Codable {
    /// Indicates that the metric already exists.
    case alreadyExists
    /// Indicates a failure status for the metric.
    case fail
    /// Indicates a start status for the metric.
    case start
    /// Indicates a success status for the metric.
    case success
}
