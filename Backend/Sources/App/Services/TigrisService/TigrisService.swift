// TigrisService.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import DataTypes
import Fluent
import SotoS3
import Vapor

internal struct TigrisService: ~Copyable {
    public let client: S3

    init() throws {
        let clientAuth = try AWSClient(
            credentialProvider: .static(
                accessKeyId: Environment.getOrThrow("TIGRIS_ACCESS_KEY_ID"),
                secretAccessKey: Environment.getOrThrow("TIGRIS_ACCESS_KEY_SECRET")
            )
        )

        client = try S3(
            client: clientAuth,
            region: .init(rawValue: "auto"),
            endpoint: Environment.getOrThrow("TIGRIS_BASE_URL")
        )
    }

    deinit {
        do {
            try client.client.syncShutdown()
        } catch {}
    }

    public func get(_: String) throws -> String {
        ""
    }

    public func publicUrl(_: String) throws -> String {
        ""
    }

    public func sign(input: String, expiresIn: TimeAmount) async throws -> String {
        let url = try await client
            .signURL(
                url: URL(string: getTigrisUrl(input))!,
                httpMethod: .GET,
                expires: expiresIn
            )

        return url.absoluteString
    }

    public func put(
        input: String,
        content: ByteBuffer,
        acl: S3.ObjectCannedACL = .private,
        metadata: [String: String]? = nil,
        expires: Date? = nil,
        contentType: String? = nil
    ) async throws -> S3.PutObjectOutput? {
        do {
            let path = try decodeS3Path(input)

            let output = try await client
                .putObject(
                    acl: acl,
                    body: .init(buffer: content),
                    bucket: path.bucket,
                    contentType: contentType, expires: expires,
                    key: path.key,
                    metadata: metadata
                )

            BackendMetric.totalMediaFilesUploadedToTigris.increment()
            return output
        } catch {
            BackendMetric.totalMediaFilesUploadedToTigrisFailed.increment()
            throw error
        }
    }

    public func decodeS3Path(_ s3Path: String) throws -> Self.S3Path {
        public var pathComponents = s3Path.pathComponents

        if pathComponents.count < 3 {
            throw GenericErrors.s3PathTooShort
        }

        let bucket = pathComponents[1].description
        pathComponents.removeFirst(2)

        let key = pathComponents.map(\.description).joined(separator: "/")

        return .init(bucket: bucket, key: key)
    }

    public func getTigrisUrl(
        _ s3Path: String
    ) throws -> String {
        let path = try decodeS3Path(s3Path)

        let tigrisUrl = client.endpoint

        let environment = try Environment.getOrThrow("ENVIRONMENT")

        let url = URL(string: tigrisUrl)

        guard let url, let host = url.host() else {
            throw GenericErrors.invalidUrl
        }

        if environment == "local" {
            return url
                .appending(path: path.bucket)
                .appending(path: path.key).absoluteString
        } else {
            guard let returnableUrl = URL(
                string: "https://\(path.bucket).\(host)/\(path.key)"
            )?.absoluteString else {
                throw GenericErrors.invalidUrl
            }

            return returnableUrl
        }
    }

    struct S3Path {
        public let bucket: String
        public let key: String
    }
}
