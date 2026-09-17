//
//  CharacterDecodingTests.swift
//  RickAndMortyTests
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation
import Testing
@testable import RickAndMorty

@Suite("Character JSON decoding", .mockDependencies)
struct CharacterDecodingTests {
    @Test("Decodes a page of characters from the real API shape")
    func decodesPage() throws {
        let page = try JSONDecoder.rickAndMorty().decode(CharacterPage.self, from: Fixtures.rickSearchJSON)

        #expect(page.info.count == 2)
        #expect(page.results.count == 2)

        let rick = try #require(page.results.first)
        #expect(rick.id == 1)
        #expect(rick.name == "Rick Sanchez")
        #expect(rick.species == "Human")
        #expect(rick.status == "Alive")
        #expect(rick.origin.name == "Earth (C-137)")
        #expect(rick.image == URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"))
    }

    @Test("Parses ISO 8601 created dates with fractional seconds")
    func decodesFractionalSecondDate() throws {
        let page = try JSONDecoder.rickAndMorty().decode(CharacterPage.self, from: Fixtures.rickSearchJSON)
        let rick = try #require(page.results.first)

        // 2017-11-04T18:48:46.250Z
        #expect(rick.created.timeIntervalSince1970 == 1_509_821_326.25)
    }

    @Test("hasType reflects whether the API supplied a non-empty type")
    func hasType() throws {
        let page = try JSONDecoder.rickAndMorty().decode(CharacterPage.self, from: Fixtures.rickSearchJSON)

        #expect(page.results[0].hasType == false)
        #expect(page.results[1].hasType == true)
        #expect(page.results[1].type == "Clone")
    }
}
