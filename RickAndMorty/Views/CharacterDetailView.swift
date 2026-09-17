//
//  CharacterDetailView.swift
//  RickAndMorty
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import SwiftUI

/// Full details for one character: name, full-width image, species, status, origin,
/// type (only when the API supplied one), and a formatted creation date.
struct CharacterDetailView: View {
    /// The character to display.
    let character: Character

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(character.name)
                    .font(.largeTitle.bold())
                    .padding(.horizontal)

                CharacterImage(url: character.image)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)

                VStack(alignment: .leading, spacing: 12) {
                    detailRow("Species", character.species)
                    detailRow("Status", character.status)
                    detailRow("Origin", character.origin.name)
                    if character.hasType {
                        detailRow("Type", character.type)
                    }
                    detailRow("Created", character.created.formatted(date: .long, time: .shortened))
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    /// A caption-style label above its value, read as one accessibility element.
    private func detailRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("With type") {
    NavigationStack {
        CharacterDetailView(character: Character.previewCharacters[2])
    }
}

#Preview("Without type") {
    NavigationStack {
        CharacterDetailView(character: Character.previewCharacters[0])
    }
}
