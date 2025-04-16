// shell.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Foundation

public struct ShellOutput {
    public let stdout: String?
    public let stderr: String?
    public let exitStatus: Int
    public let isError: Bool
    public let command: String
}

public enum OperatingSystem {
    case linux
    case macos
    case unknown(value: String)
}

public struct Shell {
    public let operatingSystem: OperatingSystem
    public let copyCommand: String

    init() throws {
        operatingSystem = try Self.getOperatingSystem()
        copyCommand = Self.getCopyCommand(os: operatingSystem)
    }

    @discardableResult
    public static func run(_ command: String) -> ShellOutput {
        let task = Process()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()

        task.standardOutput = stdoutPipe
        task.standardError = stderrPipe
        task.executableURL = URL(filePath: "/bin/zsh")

        let fullCommand = "\(command)"
        task.arguments = ["-c", fullCommand]

        task.standardInput = nil
        try! task.run()

        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

        let stdoutOutput = String(data: stdoutData, encoding: .utf8)
        let stderrOutput = String(data: stderrData, encoding: .utf8)

        task.waitUntilExit()

        let status = Int(task.terminationStatus)

        return .init(
            stdout: stdoutOutput,
            stderr: stderrOutput,
            exitStatus: status,
            isError: status != 0,
            command: command
        )
    }

    private static func getOperatingSystem() throws -> OperatingSystem {
        let result = Self.run("uname -s")

        guard
            let output = result.stdout
        else {
            throw CLIErrors.shellError(
                message: "Could not get operating system output from stdout.",
                error: result.stderr
            )
        }

        switch output {
        case "Darwin":
            return .macos
        case "Linux":
            return .linux
        default:
            return .unknown(value: output)
        }
    }

    private static func getCopyCommand(os operatingSystem: OperatingSystem) -> String {
        switch operatingSystem {
        case .macos:
            "pbcopy"
        case .linux, .unknown:
            "/tmp/\(UUID().uuidString)"
        }
    }
}
