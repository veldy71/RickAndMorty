//
//  MockCharacterService.swift
//  RickAndMortyTests
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation
@testable import RickAndMorty

/// Scriptable `CharacterService` for view-model tests.
///
/// Create one with `MockCharacterService()` and script it either by assigning
/// `handler` directly or by chaining one of the functional configuration
/// methods, e.g. `MockCharacterService().returning(characters)`.
final class MockCharacterService: CharacterService, @unchecked Sendable {
    /// Signature of the closure that answers each search; receives the requested name.
    typealias Handler = @Sendable (String) async throws -> [Character]

    private let lock = NSLock()
    private var _receivedNames: [String] = []
    private var _handler: Handler = { _ in [] }

    /// The closure backing `searchCharacters(name:)`. Returns no characters until scripted.
    var handler: Handler {
        get { lock.withLock { _handler } }
        set { lock.withLock { _handler = newValue } }
    }

    /// Every `name` passed to `searchCharacters(name:)` so far, in order.
    var receivedNames: [String] {
        lock.withLock { _receivedNames }
    }

    /// Returns `characters` for every search.
    @discardableResult
    func returning(_ characters: [Character]) -> Self {
        handler = { _ in characters }
        return self
    }

    /// Throws `error` for every search.
    @discardableResult
    func throwing(_ error: Error) -> Self {
        handler = { _ in throw error }
        return self
    }

    /// Runs `handler` for every search, letting the test vary the result by name.
    @discardableResult
    func handling(_ handler: @escaping Handler) -> Self {
        self.handler = handler
        return self
    }

    /// Records `name` and forwards to `handler`.
    func searchCharacters(name: String) async throws -> [Character] {
        lock.withLock { _receivedNames.append(name) }
        return try await handler(name)
    }
}
