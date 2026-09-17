//
//  CharacterPage.swift
//  RickAndMorty
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation

/// One page of results from `GET /api/character`.
struct CharacterPage: Codable, Sendable {
    /// Pagination metadata for the whole result set.
    let info: Info
    /// The characters on this page (at most 20).
    let results: [Character]

    /// Pagination metadata returned alongside every page.
    struct Info: Codable, Sendable {
        /// Total number of characters matching the query across all pages.
        let count: Int
        /// Total number of pages.
        let pages: Int
        /// URL of the next page, or `nil` on the last page.
        let next: String?
        /// URL of the previous page, or `nil` on the first page.
        let prev: String?
    }
}
