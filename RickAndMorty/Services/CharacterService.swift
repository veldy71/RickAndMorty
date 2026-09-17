//
//  CharacterService.swift
//  RickAndMorty
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation

/// Public interface for looking up Rick and Morty characters.
/// Views and view models depend on this protocol, never on a concrete implementation.
protocol CharacterService: Sendable {
    /// Returns characters whose name matches `name` (case-insensitive substring match, as
    /// implemented by the API). An empty `name` returns the unfiltered first page.
    /// A "no results" response from the API is surfaced as an empty array, not an error.
    ///
    /// - Parameter name: The search string typed by the user. Sent verbatim as the
    ///   `name` query parameter; percent-encoding is handled by the implementation.
    /// - Returns: The first page of matching characters, in API order.
    /// - Throws: An implementation-specific error if the lookup fails. Callers should
    ///   also expect `CancellationError` when the surrounding task is cancelled.
    func searchCharacters(name: String) async throws -> [Character]
}

