// routes.swift
// was created on 10/22/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { _ async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        do {
            try await Todo().save(on: req.dbWrite)
        } catch {
            return "Error saving: \(error)"
        }
        return ""
    }

    try app.register(collection: TodoController())
}
