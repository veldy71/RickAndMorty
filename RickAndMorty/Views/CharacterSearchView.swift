//
//  CharacterSearchView.swift
//  RickAndMorty
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import SwiftUI

/// Search bar on top, results list below. Tapping a character's image opens its detail view.
struct CharacterSearchView: View {

    @State private var viewModel: CharacterSearchViewModel
    
    /// Navigation stack contents; a pushed `Character` shows `CharacterDetailView`.
    @State private var path: [Character] = []

    /// Creates the screen around an externally constructed view model, so the
    /// caller controls which `CharacterService` is used.
    init(viewModel: CharacterSearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $path) {
            List(viewModel.characters) { character in
                CharacterRowView(character: character) {
                    path.append(character)
                }
            }
            .listStyle(.plain)
            .safeAreaInset(edge: .top, spacing: 0) { searchProgressBanner }
            .overlay { statusOverlay }
            .navigationTitle("Characters")
            .navigationDestination(for: Character.self) { character in
                CharacterDetailView(character: character)
            }
        }
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search characters by name"
        )
        .autocorrectionDisabled()
        .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
        .task { viewModel.loadInitialResults() }
    }

    /// Non-blocking progress indicator pinned directly below the search bar.
    /// The list and search field remain fully interactive while it is shown.
    @ViewBuilder
    private var searchProgressBanner: some View {
        if viewModel.isLoading {
            HStack(spacing: 8) {
                ProgressView()
                Text("Searching…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(.bar)
            .transition(.move(edge: .top).combined(with: .opacity))
            .accessibilityElement(children: .combine)
        }
    }

    /// Centered messaging for the error and "no results" states. Empty otherwise.
    @ViewBuilder
    private var statusOverlay: some View {
        if let message = viewModel.errorMessage {
            ContentUnavailableView(
                "Something Went Wrong",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
        } else if viewModel.characters.isEmpty, !viewModel.isLoading, !viewModel.searchText.isEmpty {
            ContentUnavailableView.search(text: viewModel.searchText)
        }
    }
}

#Preview {
    CharacterSearchView(
        viewModel: CharacterSearchViewModel(
            service: PreviewCharacterService(),
            debounce: .zero
        )
    )
}
