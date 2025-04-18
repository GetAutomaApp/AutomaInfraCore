// NetworkChecker.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Foundation
import Network

public class NetworkManager: ObservableObject, @unchecked Sendable {
    public let monitor = NWPathMonitor()
    public let queue = DispatchQueue(label: "NetworkManager")
    public var isConnected = true

    public init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async { [self] in
                Task {
                    await MainActor.run {
                        self.isConnected = path.status == .satisfied
                        self.objectWillChange.send()
                    }
                }
            }
        }

        monitor.start(queue: queue)
    }

    deinit {}
}
