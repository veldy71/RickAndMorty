//
//  Fixtures.swift
//  RickAndMortyTests
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation
@testable import RickAndMorty

/// Canned data shared across test suites.
enum Fixtures {
    /// Trimmed real response for `GET /api/character/?name=rick`.
    static let rickSearchJSON = Data("""
    {
      "info": { "count": 2, "pages": 1, "next": null, "prev": null },
      "results": [
        {
          "id": 1,
          "name": "Rick Sanchez",
          "status": "Alive",
          "species": "Human",
          "type": "",
          "gender": "Male",
          "origin": { "name": "Earth (C-137)", "url": "https://rickandmortyapi.com/api/location/1" },
          "location": { "name": "Citadel of Ricks", "url": "https://rickandmortyapi.com/api/location/3" },
          "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
          "episode": ["https://rickandmortyapi.com/api/episode/1"],
          "url": "https://rickandmortyapi.com/api/character/1",
          "created": "2017-11-04T18:48:46.250Z"
        },
        {
          "id": 8,
          "name": "Adjudicator Rick",
          "status": "Dead",
          "species": "Human",
          "type": "Clone",
          "gender": "Male",
          "origin": { "name": "unknown", "url": "" },
          "location": { "name": "Citadel of Ricks", "url": "https://rickandmortyapi.com/api/location/3" },
          "image": "https://rickandmortyapi.com/api/character/avatar/8.jpeg",
          "episode": ["https://rickandmortyapi.com/api/episode/28"],
          "url": "https://rickandmortyapi.com/api/character/8",
          "created": "2017-11-04T20:03:34.737Z"
        }
      ]
    }
    """.utf8)

    /// The body the API returns with HTTP 404 when a filter matches nothing.
    static let notFoundJSON = Data(#"{"error":"There is nothing here"}"#.utf8)

    /// Builds a minimal `Character` for tests that only care about identity and name.
    /// - Parameters:
    ///   - id: The character's `id`.
    ///   - name: The character's `name`.
    ///   - type: The optional sub-type; empty by default so `hasType` is `false`.
    static func character(id: Int, name: String, type: String = "") -> Character {
        Character(
            id: id,
            name: name,
            status: "Alive",
            species: "Human",
            type: type,
            gender: "Male",
            origin: Character.Location(name: "Earth", url: ""),
            location: Character.Location(name: "Earth", url: ""),
            image: URL(string: "https://example.com/\(id).jpeg")!,
            created: Date(timeIntervalSince1970: 0)
        )
    }
}
