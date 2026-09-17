//
//  CharacterSearchViewModelTests.swift
//  RickAndMortyTests
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation
import Testing
@testable import RickAndMorty

@Suite("CharacterSearchViewModel", .mockDependencies)
@MainActor
struct CharacterSearchViewModelTests {
    @Test("Changing the search text queries the service and publishes the results")
    func searchTextTriggersSearch() async {
        let expected = [Fixtures.character(id: 1, name: "Rick Sanchez")]
        let service = MockCharacterService().returning(expected)
        let viewModel = CharacterSearchViewModel(service: service, debounce: .zero)

        viewModel.searchText = "rick"
        await viewModel.searchTask?.value

        #expect(service.receivedNames == ["rick"])
        #expect(viewModel.characters == expected)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("Initial load fetches the unfiltered list once")
    func initialLoad() async {
        let service = MockCharacterService().returning([Fixtures.character(id: 2, name: "Morty Smith")])
        let viewModel = CharacterSearchViewModel(service: service, debounce: .zero)

        viewModel.loadInitialResults()
        viewModel.loadInitialResults()
        await viewModel.searchTask?.value

        #expect(service.receivedNames == [""])
        #expect(viewModel.characters.map(\.name) == ["Morty Smith"])
    }

    @Test("A newer keystroke supersedes an older, slower search")
    func latestSearchWins() async {
        let service = MockCharacterService().handling { name in
            // "ri" is slow; "rick" is fast. The slow response must not overwrite the fast one.
            if name == "ri" {
                try await Task.sleep(for: .milliseconds(200))
                return [Fixtures.character(id: 99, name: "Stale Result")]
            }
            return [Fixtures.character(id: 1, name: "Rick Sanchez")]
        }
        let viewModel = CharacterSearchViewModel(service: service, debounce: .zero)

        viewModel.searchText = "ri"
        let first = viewModel.searchTask
        viewModel.searchText = "rick"
        let second = viewModel.searchTask

        await first?.value
        await second?.value

        #expect(viewModel.characters.map(\.name) == ["Rick Sanchez"])
        #expect(viewModel.isLoading == false)
    }

    @Test("isLoading is true while a search is in flight")
    func loadingState() async {
        let gate = AsyncGate()
        let service = MockCharacterService().handling { _ in
            await gate.wait()
            return []
        }
        let viewModel = CharacterSearchViewModel(service: service, debounce: .zero)

        viewModel.searchText = "rick"
        await Task.yield()
        // Let the task get past the (zero) debounce and into the service call.
        while !viewModel.isLoading { await Task.yield() }
        #expect(viewModel.isLoading == true)

        await gate.open()
        await viewModel.searchTask?.value
        #expect(viewModel.isLoading == false)
    }

    @Test("Service errors clear the list and expose a message")
    func errorState() async {
        let service = MockCharacterService().throwing(APIError.httpStatus(503))
        let viewModel = CharacterSearchViewModel(service: service, debounce: .zero)

        viewModel.searchText = "rick"
        await viewModel.searchTask?.value

        #expect(viewModel.characters.isEmpty)
        #expect(viewModel.errorMessage == APIError.httpStatus(503).errorDescription)
    }
}

/// A one-shot latch that suspends callers until `open()` is called.
private actor AsyncGate {
    private var isOpen = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    /// Suspends until `open()` has been called. Returns immediately if it already has.
    func wait() async {
        if isOpen { return }
        await withCheckedContinuation { waiters.append($0) }
    }

    /// Releases every current and future `wait()`.
    func open() {
        isOpen = true
        waiters.forEach { $0.resume() }
        waiters.removeAll()
    }
}
