// entrypoint.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import FlyingFox
import Logging
import Metrics
import NIOCore
import NIOPosix
import Prometheus
import Vapor

@main
enum Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)

        let app = try await Application.make(env)

        try await startPrometheusService()

        // This attempts to install NIO as the Swift Concurrency global executor.
        // You can enable it if you'd like to reduce the amount of context switching between NIO and Swift Concurrency.
        // Note: this has caused issues with some libraries that use `.wait()` and cleanly shutting down.
        // If enabled, you should be careful about calling async functions before this point as it can cause assertion
        // failures.
        // let executorTakeoverSuccess =
        // NIOSingletons.unsafeTryInstallSingletonPosixEventLoopGroupAsConcurrencyGlobalExecutor()
        // app.logger.debug("Tried to install SwiftNIO's EventLoopGroup as Swif s global concurrency executor",
        // metadata:
        // ["success": .stringConvertible(executorTakeoverSuccess)])

        do {
            try await configure(app)
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        try await app.execute()
        try await app.asyncShutdown()
    }

    static func startMetricsServer() {}
}

public func startPrometheusService() async throws {
    Task {
        let port = try Environment.getOrThrow("PROMETHEUS_PORT")
        guard
            let prometheusPort = UInt16(port)
        else {
            throw Abort(.custom(
                code: 500,
                reasonPhrase: "PROMETHEUS_PORT '\(port)' could not be converted to a UInt16."
            ))
        }
        let server = HTTPServer(port: prometheusPort)

        await server.appendRoute("Prometheus/metrics") { _ in
            let metrics = MetricsService.global.emit()
            return HTTPResponse(
                statusCode: .ok,
                body: metrics
            )
        }

        try await server.run()
    }
    try await Task.sleep(for: .seconds(10))
    print("Prometheus server started")
}
