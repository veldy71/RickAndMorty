//
//  AppDependencyProvider.swift
//  RickAndMorty
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation

/// Production wiring: real implementations talking to rickandmortyapi.com.
///
/// Instantiated once in `RickAndMortyApp.init` and handed to `Locator.shared`.
class AppDependencyProvider: DependencyProvider {
    /// Live service backed by `URLSession`.
    var characterService: CharacterService = AppCharacterService(client: URLSessionHTTPClient())
}
