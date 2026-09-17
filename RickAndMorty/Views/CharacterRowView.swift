//
//  CharacterRowView.swift
//  RickAndMorty
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import SwiftUI

/// A single search result: image, name, and species.
/// Only the image is tappable, per the spec ("tapping on an image…").
struct CharacterRowView: View {
    /// The character to display.
    let character: Character
    
    /// Invoked when the user taps the character's image.
    let onImageTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onImageTap) {
                CharacterImage(url: character.image)
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            // `.borderless` keeps the tap target limited to the image instead of the whole row.
            .buttonStyle(.borderless)
            .accessibilityLabel("Show details for \(character.name)")

            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                Text(character.species)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}

/// Remote image with placeholder and failure states.
struct CharacterImage: View {
    /// Location of the image to load.
    let url: URL

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Color(.secondarySystemBackground)
                    ProgressView()
                }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                ZStack {
                    Color(.secondarySystemBackground)
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
            @unknown default:
                Color(.secondarySystemBackground)
            }
        }
    }
}

#Preview {
    NavigationStack {
        List(Character.previewCharacters) { CharacterRowView(character: $0, onImageTap: {}) }
            .listStyle(.plain)
    }
}
