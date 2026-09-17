//
//  Character.swift
//  RickAndMorty
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation

/// A character returned by the Rick and Morty API.
/// Field names mirror the API's JSON keys so the default `Codable` synthesis applies.
struct Character: Codable, Identifiable, Hashable, Sendable {
    /// Unique identifier assigned by the API.
    let id: Int
    /// Display name, e.g. `"Rick Sanchez"`.
    let name: String
    /// Life status as reported by the API: `"Alive"`, `"Dead"`, or `"unknown"`.
    let status: String
    /// Species, e.g. `"Human"` or `"Alien"`.
    let species: String
    /// Optional sub-type, e.g. `"Clone"`. The API sends `""` when there is none; see `hasType`.
    let type: String
    /// Gender as reported by the API: `"Female"`, `"Male"`, `"Genderless"`, or `"unknown"`.
    let gender: String
    /// Where the character comes from.
    let origin: Location
    /// The character's last known location.
    let location: Location
    /// URL of the character's 300×300 avatar image.
    let image: URL
    /// When the record was added to the API's database.
    let created: Date

    /// A named location reference (origin / last known location).
    struct Location: Codable, Hashable, Sendable {
        /// Human-readable location name, or `"unknown"`.
        let name: String
        /// API URL for the full location record. Empty when the location is unknown.
        let url: String
    }

    /// The API returns `""` when a character has no sub-type; treat that as "not available".
    var hasType: Bool {
        !type.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
