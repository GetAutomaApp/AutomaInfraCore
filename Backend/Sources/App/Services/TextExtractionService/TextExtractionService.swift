// TextExtractionService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import SotoTextract
import Vapor

internal struct TextExtractionService: ~Copyable {
    let client: Textract

    init() {
        client = Textract(
            client: .init(),
            region: .useast1
        ) // We don't have it in the `default-region` we set in the env
    }

    func getText(from image: Data) async throws -> Textract.DetectDocumentTextResponse {
        try await client.detectDocumentText(.init(document: .init(
            bytes: .base64(image.base64EncodedString())
        )))
    }

    func getTextToSimpleString(from image: Data) async throws -> String {
        let response = try await getText(from: image)

        return response.blocks!
            .map { $0.text ?? "" }
            .filter(\.isEmpty)
            .joined(separator: " ")
            .trimmingCharacters(in: .init(charactersIn: " "))
    }

    deinit {
        do {
            try client.client.syncShutdown()
        } catch {}
    }
}
