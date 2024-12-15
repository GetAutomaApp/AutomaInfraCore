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
        try await Todo().save(on: req.dbWrite)
        return ""
    }

    try app.register(collection: TodoController())
}
