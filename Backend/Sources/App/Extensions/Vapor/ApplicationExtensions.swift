// ApplicationExtensions.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Temporal
import Vapor

internal extension Application {
    var temporalClient: TemporalClient {
        try! TemporalClient(
            target: .dns(
                host: TemporalClient.getServerHostnameFromEnv(),
                port: 7_233
            ),
            transportSecurity: .plaintext,
            configuration: .init(instrumentation: .init(serverHostname: "temporal")),
            logger: Logger(label: "temporal-client")
        )
    }
}
