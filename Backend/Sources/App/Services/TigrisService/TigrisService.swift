// TigrisService.swift
// was created on 12/26/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import Fluent
import SotoS3
import Vapor

import SotoS3FileTransfer

struct TigrisService: ~Copyable {
    let client: S3
    let s3FileTransferManager: S3FileTransferManager

    let tigrisBaseUrl = "https://fly.storage.tigris.dev"

    init() throws {
        let clientAuth = try AWSClient(
            credentialProvider: .static(
                accessKeyId: Environment.getOrThrow("TIGRIS_ACCESS_KEY_ID"),
                secretAccessKey: Environment.getOrThrow("TIGRIS_ACCESS_KEY_SECRET")
            )
        )

        client = S3(
            client: clientAuth,
            region: .init(rawValue: "auto"),
            endpoint: tigrisBaseUrl
        )

        s3FileTransferManager = .init(s3: client)
    }

    deinit {
        do {
            try client.client.syncShutdown()
        } catch {}
    }

    func get(_: String) async throws -> String {
        ""
    }

    func publicUrl(_: String) throws -> String {
        ""
    }

    func sign(input: String, expiresIn: TimeAmount) async throws -> String {
        let url = try await client
            .signURL(
                url: URL(string: getTigrisUrl(input))!,
                httpMethod: .GET,
                expires: expiresIn
            )

        return url.absoluteString
    }

    func put(
        input: String,
        content: ByteBuffer,
        acl: S3.ObjectCannedACL = .private,
        metadata: [String: String]? = nil,
        expires: Date? = nil
    ) async throws -> S3.PutObjectOutput? {
        let path = try decodeS3Path(input)

        let output = try await client
            .putObject(
                acl: acl,
                body: .init(buffer: content),
                bucket: path.bucket,
                expires: expires,
                key: path.key,
                metadata: metadata
            )

        return output
    }

    func decodeS3Path(_ s3Path: String) throws -> TigrisService.S3Path {
        var pathComponents = s3Path.pathComponents

        if pathComponents.count < 3 {
            throw Abort(.conflict, reason: "Invalid S3 path")
        }

        let bucket = pathComponents[1].description
        pathComponents.removeFirst(2)

        let key = pathComponents.map(\.description).joined(separator: "/")

        return .init(bucket: bucket, key: key)
    }

    func getTigrisUrl(
        _ s3Path: String
    ) throws -> String {
        let path = try decodeS3Path(s3Path)

        let tigrisUrl = client.endpoint

        let environment = try Environment.getOrThrow("ENVIRONMENT")

        // TODO: (We have a task for this)
//        if environment == "local" {
//            return "http://localhost:4566"
//        } else {
        return "https://\(path.bucket).fly.storage.tigris.dev/\(path.key)"
//        }
    }

    struct S3Path {
        let bucket: String
        let key: String
    }
}
