// SendTransactionalMessageWorkflow.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Temporal
import Vapor

@Workflow
internal final class SendTransactionalMessageWorkflow {
    func run(input: SendTransactionalMessageActivityInput) async throws {
        try await Workflow.executeActivity(
            TransactionalMessageActivities.Activities.SendMessage.self,
            options: ActivityOptions(startToCloseTimeout: .seconds(30)),
            input: input
        )
    }
}
