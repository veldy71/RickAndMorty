//
//  MockHTTPClient.swift
//  RickAndMortyTests
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation
@testable import RickAndMorty

/// Records the request it receives and returns a canned response.
final class MockHTTPClient: HTTPClient, @unchecked Sendable {
    /// What the client should do when a request arrives.
    enum Stub {
        /// Return `Data` with the given HTTP status code.
        case success(Data, statusCode: Int)
        /// Throw `Error`, simulating a transport failure.
        case failure(Error)
    }

    private let lock = NSLock()
    private var _requests: [URLRequest] = []
    /// The response to produce for every request. May be reassigned between calls.
    var stub: Stub

    /// Creates a client that answers every request with `stub`.
    init(stub: Stub) {
        self.stub = stub
    }

    /// Every request received so far, in order.
    var requests: [URLRequest] {
        lock.withLock { _requests }
    }

    /// Records `request` and replays `stub`.
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        lock.withLock { _requests.append(request) }
        switch stub {
        case .success(let data, let statusCode):
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            return (data, response)
        case .failure(let error):
            throw error
        }
    }
}
