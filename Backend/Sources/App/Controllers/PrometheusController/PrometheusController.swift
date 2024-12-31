// PrometheusController.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Metrics
import Prometheus
import Vapor

struct PrometheusController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let prometheusRoute = routes.grouped("Prometheus")

        prometheusRoute.get("metrics", use: metrics)
    }

    @Sendable
    func metrics(req _: Request) async throws -> String {
        MetricsService.global.emit()
    }
}
