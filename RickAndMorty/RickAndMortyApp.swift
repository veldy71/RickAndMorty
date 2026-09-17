//
//  RickAndMortyApp.swift
//  RickAndMorty
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import SwiftUI

/// Application entry point and composition root.
///
/// Registers the production `DependencyProvider` with `Locator.shared` before any
/// view is created, then builds the root screen with its dependencies injected.
@main
struct RickAndMortyApp: App {

    @Inject private var characterService: CharacterService

    /// Registers the app's dependencies. Runs before `body` is first evaluated.
    init() {
        // Register the app's dependencies with the locator so `@Inject` can resolve them.
        AppDependencyProvider().provide(locator: .shared)
    }

    /// A single window hosting the character search screen.
    var body: some Scene {
        WindowGroup {
            CharacterSearchView(
                viewModel: CharacterSearchViewModel(service: characterService)
            )
        }
    }
}
