// ChatCompletion.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Vapor

protocol ChatCompletion {}

extension ChatCompletion {
    func validateModel(model _: ChatCompletion, platform: String) {
        switch platform {
        case "openai":
            print("OpenAI model is valid")
        default:
            print("Model is invalid")
        }
    }
}
