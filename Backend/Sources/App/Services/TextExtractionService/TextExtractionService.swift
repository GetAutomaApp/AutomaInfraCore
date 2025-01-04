// TextExtractionService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import SotoTextract
import Vapor

struct TextExtractionService {
    let client: Textract

    init() {
        client = Textract(client: .init())
    }

    func getText(from image: Data) async throws -> String {
        let response = try await client.detectDocumentText(.init(document: .init(
            bytes: .base64(image.base64EncodedString())
        )))

        var text = ""
        for block in response.blocks! {
            text += block.text ?? ""
        }

        return response.blocks!
            .map { $0.text ?? "" }
            .filter(\.isEmpty)
            .joined(separator: " ")
            .trim()
    }
}
