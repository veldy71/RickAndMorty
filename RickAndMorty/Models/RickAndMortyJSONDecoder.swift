//
//  RickAndMortyJSONDecoder.swift
//  RickAndMorty
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation

extension JSONDecoder {
    /// A decoder configured for the Rick and Morty API.
    ///
    /// The API emits ISO 8601 timestamps with fractional seconds
    /// (e.g. `2017-11-04T18:48:46.250Z`), which Foundation's built-in
    /// `.iso8601` strategy does not accept, so a custom strategy is used.
    static func rickAndMorty() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            
            if let date = try? Date(raw, strategy: .iso8601WithFractionalSeconds) {
                return date
            }
            
            if let date = try? Date(raw, strategy: .iso8601) {
                return date
            }
            
            // If all else fails, throw an error.
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unrecognised ISO 8601 date: \(raw)"
            )
        }
        return decoder
    }
}

private extension ParseStrategy where Self == Date.ISO8601FormatStyle {
    /// ISO 8601 parsing that accepts fractional seconds, e.g. `2017-11-04T18:48:46.250Z`.
    static var iso8601WithFractionalSeconds: Date.ISO8601FormatStyle {
        Date.ISO8601FormatStyle(includingFractionalSeconds: true)
    }
}
