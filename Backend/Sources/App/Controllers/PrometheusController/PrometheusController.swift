// PrometheusController.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import Prometheus
import Vapor

struct PrometheusController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let prometheusRoute = routes.grouped("Prometheus")

        prometheusRoute.get("metrics", use: metrics)
    }

    @Sendable
    func metrics(req: Request) throws -> String {
        try validate(req: req)
        guard
            let metrics = String(data: MetricsService.global.emit(), encoding: .utf8)
        else {
            try MessageService().sendDiscordAlert(
                alertTitle: "Could not convert metrics to string.",
                error: PrometheusControllerError.couldNotConvertMetricsToData,
                logger: req.logger
            )
            throw PrometheusControllerError.couldNotConvertMetricsToData
        }
        return metrics
    }

    private func validate(req: Request) throws {
        let query = try req.query.decode(PrometheusRouteQuery.self)
        let token = try Environment.getOrThrow("FLY_METRICS_TOKEN")

        guard query.authToken == token else {
            throw PrometheusControllerError.invalidAuthToken
        }
    }
}
