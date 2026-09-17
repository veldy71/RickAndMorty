//
//  CharacterSearchViewModel.swift
//  RickAndMorty
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation
import Observation

/// Drives the character search screen.
///
/// Every change to `searchText` cancels any in-flight lookup and starts a new one,
/// so the list always reflects the most recent keystroke. A short debounce keeps
/// fast typing from hammering the API while still updating after each change.
@Observable
@MainActor
final class CharacterSearchViewModel {
    /// The current search string. Bind this to the search field; every change
    /// schedules a new search and cancels the previous one.
    var searchText: String = "" {
        didSet {
            guard searchText != oldValue else { return }
            scheduleSearch()
        }
    }

    /// Results of the most recently completed search. Empty until the first response
    /// arrives, and cleared when a search fails.
    private(set) var characters: [Character] = []
    /// `true` while any search is scheduled or awaiting a response, including during the
    /// debounce window, so a progress indicator can appear on the first keystroke.
    private(set) var isLoading = false
    /// User-presentable description of the last failure, or `nil` after a successful search.
    private(set) var errorMessage: String?

    /// The most recently scheduled search. Exposed so tests can `await` its completion.
    private(set) var searchTask: Task<Void, Never>?

    private let service: CharacterService
    private let debounce: Duration
    /// Number of `search(name:)` calls currently executing. Drives `isLoading`.
    private var inFlightCount = 0 {
        didSet { isLoading = inFlightCount > 0 }
    }

    /// Creates a view model.
    /// - Parameters:
    ///   - service: Performs the actual character lookups.
    ///   - debounce: How long to wait after the last keystroke before hitting the
    ///     service. Pass `.zero` in tests to make searches run immediately.
    init(service: CharacterService, debounce: Duration = .milliseconds(300)) {
        self.service = service
        self.debounce = debounce
    }

    /// Runs the initial (empty-string) search. Call once when the screen appears.
    func loadInitialResults() {
        guard searchTask == nil else { return }
        scheduleSearch()
    }

    /// Cancels any pending search and starts a new one for the current `searchText`.
    private func scheduleSearch() {
        searchTask?.cancel()
        let query = searchText
        searchTask = Task { [weak self] in
            await self?.search(name: query)
        }
    }

    /// Performs a single search for `name`, applying results only if this call has not
    /// been superseded by a newer one.
    ///
    /// Normally invoked via `searchText`'s observer; exposed so it can be driven directly.
    /// Honors task cancellation at each suspension point: a cancelled call leaves
    /// `characters` and `errorMessage` untouched for the newer search to update.
    /// - Parameter name: The search string to send to the service.
    func search(name: String) async {
        // Count the task as in flight from the very first keystroke so the progress
        // indicator appears immediately, including during the debounce window.
        inFlightCount += 1
        defer { inFlightCount -= 1 }

        if debounce > .zero {
            try? await Task.sleep(for: debounce)
        }
        guard !Task.isCancelled else { return }

        do {
            let results = try await service.searchCharacters(name: name)
            guard !Task.isCancelled else { return }
            characters = results
            errorMessage = nil
        } catch is CancellationError {
            // Superseded by a newer search; leave state for the newer task to update.
        } catch {
            guard !Task.isCancelled else { return }
            characters = []
            errorMessage = error.localizedDescription
        }
    }
}
