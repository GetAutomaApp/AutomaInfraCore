// metrics.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

//
//  metrics.swift
//  Backend
//
//  Created by Simon Ferns on 12/30/24.
//
import Metrics
import Prometheus

struct MetricsInitializer {
    static let global = MetricsInitializer()

    private var prometheus: PrometheusCollectorRegistry

    private init() {
        let prometheusRegistry = PrometheusCollectorRegistry()
        let myProm = PrometheusMetricsFactory(registry: prometheusRegistry)
        MetricsSystem.bootstrap(myProm)

        prometheus = prometheusRegistry
    }

    func emit() -> String {
        var buffer = [UInt8]()
        prometheus.emit(into: &buffer)
        return String(decoding: buffer, as: Unicode.UTF8.self)
    }

    func makeCounter(name: String, labels: [String: String] = [:]) -> Prometheus.Counter {
        prometheus
            .makeCounter(
                name: name,
                labels: convertStringDictionaryToStringMap(labels)
            )
    }

    private func convertStringDictionaryToStringMap(_ dictionary: [String: String]) -> [(String, String)] {
        zip(dictionary.keys, dictionary.values).map { ($0.0, $0.1) }
    }
}

enum BackendMetrics {
    static let totalSuccessfulRegistrationCodesSent = MetricsInitializer.global.makeCounter(
        name: "total_registration_codes_sent",
        labels: ["status": "success"]
    )
}
