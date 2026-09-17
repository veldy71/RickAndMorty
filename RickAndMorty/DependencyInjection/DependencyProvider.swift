//
//  DependencyProvider.swift
//  RickAndMorty
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation

/// The complete set of dependencies the app needs, independent of how they are built.
///
/// Conform to this protocol once per environment — `AppDependencyProvider` for
/// production, `MockDependencyProvider` in tests — and call `provide(locator:)` at
/// start-up to register every dependency with a `Locator`. Adding a dependency means
/// adding a requirement here and a line in `provide(locator:)`, so the compiler
/// ensures every environment supplies it.
protocol DependencyProvider {
    /// Looks up Rick and Morty characters.
    var characterService: CharacterService { get }
}

extension DependencyProvider {
    /// Registers every dependency declared by this provider with `locator`.
    ///
    /// Each dependency is captured by value before being handed to the locator so the
    /// supplier closures are `@Sendable` even when the provider itself is not.
    /// - Parameter locator: The registry that `@Inject` will later resolve from.
    func provide(locator: Locator) {
        // self isn't sendable, so capture the dependencies first and then supply them
        let characterService = characterService
        
        // supply dependencies
        locator.supply { characterService }
    }
}
