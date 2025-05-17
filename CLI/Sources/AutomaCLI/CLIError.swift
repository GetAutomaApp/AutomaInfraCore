// CLIError.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

/// Error type for any errors thrown in CLI package.
public enum CLIError: Error {
    /// An error that occurred when executing a command in a shell.
    case shellError(message: String, error: String?)
}
