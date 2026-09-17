//
//  APIError.swift
//  RickAndMorty
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation

/// Errors raised by the networking layer.
///
/// Conforms to `LocalizedError` so `error.localizedDescription` yields a
/// user-presentable message that the UI can display directly.
enum APIError: Error, Equatable, LocalizedError {
    /// A request URL could not be assembled from its components.
    case invalidURL
    /// The transport returned something other than an `HTTPURLResponse`.
    case invalidResponse
    /// The server answered with a non-success status code (other than the API's
    /// "no results" 404, which is mapped to an empty result instead).
    case httpStatus(Int)
    /// The response body could not be decoded. The payload describes the decoding failure.
    case decoding(String)

    /// A short, user-presentable description of the error.
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL could not be built."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .httpStatus(let code):
            return "The server responded with status code \(code)."
        case .decoding(let detail):
            return "The response could not be read: \(detail)"
        }
    }
}
