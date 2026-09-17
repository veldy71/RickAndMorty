//
//  AppCharacterService.swift
//  RickAndMorty
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation

/// `CharacterService` backed by https://rickandmortyapi.com.
struct AppCharacterService: CharacterService {
    /// The production API root, `https://rickandmortyapi.com/api`.
    static let defaultBaseURL = URL(string: "https://rickandmortyapi.com/api")!

    private let baseURL: URL
    private let client: HTTPClient
    private let decoder: JSONDecoder

    /// Creates a service.
    /// - Parameters:
    ///   - baseURL: API root that endpoint paths are appended to. Override to point at a
    ///     staging host or a local stub server.
    ///   - client: Transport used to perform requests. Inject a mock in tests.
    ///   - decoder: Decoder for response bodies. Defaults to one configured for the
    ///     API's date format; see `JSONDecoder.rickAndMorty()`.
    init(
        baseURL: URL = AppCharacterService.defaultBaseURL,
        client: HTTPClient = URLSessionHTTPClient(),
        decoder: JSONDecoder = .rickAndMorty()
    ) {
        self.baseURL = baseURL
        self.client = client
        self.decoder = decoder
    }

    /// Performs `GET {baseURL}/character/?name={name}` and decodes the first page of results.
    ///
    /// - Returns: The decoded characters, or an empty array when the API reports no matches.
    /// - Throws: `APIError.httpStatus` for non-success responses other than the API's
    ///   "no results" 404, `APIError.decoding` if the body cannot be decoded, or any error
    ///   thrown by the underlying `HTTPClient`.
    func searchCharacters(name: String) async throws -> [Character] {
        let request = try makeSearchRequest(name: name)
        let (data, response) = try await client.data(for: request)

        switch response.statusCode {
        case 200..<300:
            do {
                return try decoder.decode(CharacterPage.self, from: data).results
            } catch {
                throw APIError.decoding(String(describing: error))
            }
        case 404:
            // The API answers `404 {"error": "There is nothing here"}` when the
            // filter matches no characters. That is a valid, empty result.
            return []
        default:
            throw APIError.httpStatus(response.statusCode)
        }
    }

    /// Builds `GET {baseURL}/character/?name={name}`. Exposed internally so it can be unit tested.
    /// - Parameter name: The raw search string; it is percent-encoded here.
    /// - Throws: `APIError.invalidURL` if the URL cannot be assembled.
    func makeSearchRequest(name: String) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appending(path: "character", directoryHint: .isDirectory),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidURL
        }
        components.queryItems = [URLQueryItem(name: "name", value: name)]
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
