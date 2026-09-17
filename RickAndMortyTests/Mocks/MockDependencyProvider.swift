//
//  MockDependencyProvider.swift
//  RickAndMortyTests
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation
@testable import RickAndMorty

/// Test wiring: every dependency is a scriptable mock.
///
/// Registered with `Locator.shared` by `MockDependenciesTrait` so anything resolved
/// via `@Inject` during tests is a test double rather than a live service.
class MockDependencyProvider: DependencyProvider {
    /// An unscripted `MockCharacterService`; returns no characters until configured.
    var characterService: CharacterService = MockCharacterService()
}
