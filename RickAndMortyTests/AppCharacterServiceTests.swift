//
//  RickAndMortyCharacterServiceTests.swift
//  RickAndMortyTests
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation
import Testing
@testable import RickAndMorty

@Suite("AppCharacterService", .mockDependencies)
struct RickAndMortyCharacterServiceTests {
    @Test("Builds the documented search URL with the name query parameter")
    func buildsSearchURL() throws {
        let service = AppCharacterService(client: MockHTTPClient(stub: .success(Data(), statusCode: 200)))

        let request = try service.makeSearchRequest(name: "rick")

        #expect(request.url?.absoluteString == "https://rickandmortyapi.com/api/character/?name=rick")
        #expect(request.httpMethod == "GET")
    }

    @Test("Percent-encodes the search string", arguments: [
        ("rick sanchez", "https://rickandmortyapi.com/api/character/?name=rick%20sanchez"),
        ("", "https://rickandmortyapi.com/api/character/?name="),
        ("a&b", "https://rickandmortyapi.com/api/character/?name=a%26b"),
    ])
    func encodesQuery(name: String, expected: String) throws {
        let service = AppCharacterService(client: MockHTTPClient(stub: .success(Data(), statusCode: 200)))

        let request = try service.makeSearchRequest(name: name)

        #expect(request.url?.absoluteString == expected)
    }

    @Test("Decodes results on a 200 response and sends the request to the client")
    func decodesSuccess() async throws {
        let client = MockHTTPClient(stub: .success(Fixtures.rickSearchJSON, statusCode: 200))
        let service = AppCharacterService(client: client)

        let characters = try await service.searchCharacters(name: "rick")

        #expect(characters.map(\.name) == ["Rick Sanchez", "Adjudicator Rick"])
        #expect(client.requests.count == 1)
        #expect(client.requests.first?.url?.query() == "name=rick")
    }

    @Test("Treats the API's 404 'nothing here' as an empty result, not an error")
    func notFoundIsEmpty() async throws {
        let client = MockHTTPClient(stub: .success(Fixtures.notFoundJSON, statusCode: 404))
        let service = AppCharacterService(client: client)

        let characters = try await service.searchCharacters(name: "zzzz")

        #expect(characters.isEmpty)
    }

    @Test("Surfaces other HTTP failures as APIError.httpStatus")
    func serverErrorThrows() async {
        let client = MockHTTPClient(stub: .success(Data(), statusCode: 500))
        let service = AppCharacterService(client: client)

        await #expect(throws: APIError.httpStatus(500)) {
            try await service.searchCharacters(name: "rick")
        }
    }

    @Test("Wraps malformed JSON in APIError.decoding")
    func malformedJSONThrows() async {
        let client = MockHTTPClient(stub: .success(Data("not json".utf8), statusCode: 200))
        let service = AppCharacterService(client: client)

        await #expect(throws: APIError.self) {
            try await service.searchCharacters(name: "rick")
        }
    }
}
