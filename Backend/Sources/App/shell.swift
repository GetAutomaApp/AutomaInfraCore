// shell.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation

struct ShellOutput {
    let stdout: String?
    let stderr: String?
    let exitStatus: Int
    let isError: Bool
    let commad: String

    init(
        stdout: String?,
        stderr: String?,
        exitStatus: Int,
        isError: Bool,
        commad: String
    ) {
        self.stdout = stdout
        self.stderr = stderr
        self.exitStatus = exitStatus
        self.isError = isError
        self.commad = commad
    }
}

struct Shell {
    @discardableResult
    func run(_ command: String) -> ShellOutput {
        let task = Process()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()

        task.standardOutput = stdoutPipe
        task.standardError = stderrPipe
        task.launchPath = "/bin/zsh"

        let fullCommand = "\(command)"
        task.arguments = ["-c", fullCommand]

        task.standardInput = nil
        task.launch()

        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

        let stdoutOutput = String(data: stdoutData, encoding: .utf8)
        let stderrOutput = String(data: stderrData, encoding: .utf8)

        task.waitUntilExit()

        let status = Int(task.terminationStatus)

        let out = stdoutOutput?.count ?? 0 > 0 ? stdoutOutput : stderrOutput

        return .init(
            stdout: stdoutOutput,
            stderr: stderrOutput,
            exitStatus: status,
            isError: status != 0,
            commad: command
        )
    }
}
