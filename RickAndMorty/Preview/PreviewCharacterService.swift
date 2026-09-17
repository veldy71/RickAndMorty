//
//  PreviewCharacterService.swift
//  RickAndMorty
//
//  Created by Thomas Veldhouse on 9/17/26.
//

#if DEBUG
import Foundation

/// In-memory `CharacterService` used by SwiftUI previews so the canvas never hits the network.
struct PreviewCharacterService: CharacterService {
    /// Filters `Character.previewCharacters` by case-insensitive substring match after a
    /// short artificial delay, so previews exercise the loading state.
    func searchCharacters(name: String) async throws -> [Character] {
        try await Task.sleep(for: .milliseconds(300))
        let needle = name.lowercased()
        return Character.previewCharacters.filter {
            needle.isEmpty || $0.name.lowercased().contains(needle)
        }
    }
}

extension Character {
    /// Sample characters for SwiftUI previews. Index 2 (`"Adjudicator Rick"`) has a
    /// non-empty `type`; the others do not.
    static let previewCharacters: [Character] = [
        Character(
            id: 1,
            name: "Rick Sanchez",
            status: "Alive",
            species: "Human",
            type: "",
            gender: "Male",
            origin: Location(name: "Earth (C-137)", url: "https://rickandmortyapi.com/api/location/1"),
            location: Location(name: "Citadel of Ricks", url: "https://rickandmortyapi.com/api/location/3"),
            image: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!,
            created: Date(timeIntervalSince1970: 1_509_821_326)
        ),
        Character(
            id: 2,
            name: "Morty Smith",
            status: "Alive",
            species: "Human",
            type: "",
            gender: "Male",
            origin: Location(name: "unknown", url: ""),
            location: Location(name: "Citadel of Ricks", url: "https://rickandmortyapi.com/api/location/3"),
            image: URL(string: "https://rickandmortyapi.com/api/character/avatar/2.jpeg")!,
            created: Date(timeIntervalSince1970: 1_509_821_534)
        ),
        Character(
            id: 8,
            name: "Adjudicator Rick",
            status: "Dead",
            species: "Human",
            type: "Clone",
            gender: "Male",
            origin: Location(name: "unknown", url: ""),
            location: Location(name: "Citadel of Ricks", url: "https://rickandmortyapi.com/api/location/3"),
            image: URL(string: "https://rickandmortyapi.com/api/character/avatar/8.jpeg")!,
            created: Date(timeIntervalSince1970: 1_509_874_246)
        ),
    ]
}
#endif
