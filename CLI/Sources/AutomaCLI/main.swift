// main.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

var env = try Environment.detect()
let app = try await Application.make(env)

defer { app.shutdown() }

app.commands.use(GenerateAppComponent(), as: "generate")

try app.run()
