//
//  HTTPClient.swift
//  RickAndMorty
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation

/// Minimal abstraction over the transport layer so services can be tested
/// without touching the network.
protocol HTTPClient: Sendable {
    /// Performs `request` and returns the response body together with its HTTP metadata.
    ///
    /// Implementations should throw for transport-level failures (no connection, timeout,
    /// non-HTTP response) and return normally for any HTTP status code; interpreting the
    /// status is the caller's responsibility.
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

/// `URLSession`-backed transport used in production.
struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    /// Creates a client that performs requests on `session`.
    /// - Parameter session: The session to use. Defaults to `URLSession.shared`.
    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Performs `request` on the underlying session.
    /// - Throws: `APIError.invalidResponse` if the response is not an `HTTPURLResponse`,
    ///   or any error thrown by `URLSession`.
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        return (data, httpResponse)
    }
}
