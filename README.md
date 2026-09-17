# RickAndMorty

An iPhone app (SwiftUI, iOS 17+) for searching characters from the
[Rick and Morty API](https://rickandmortyapi.com/).

Type in the search bar and the list updates after every keystroke with characters
whose names match. Tap a character's image to open a detail view.

## Architecture

```
RickAndMorty/
├── RickAndMortyApp.swift            # @main – registers AppDependencyProvider, resolves via @Inject
├── DependencyInjection/
│   ├── DependencyProvider.swift     # protocol listing the app's dependencies + provide(locator:)
│   ├── AppDependencyProvider.swift  # Production wiring (AppCharacterService)
│   ├── Locator.swift                # Lock-guarded service registry (supply / resolve by type)
│   └── Inject.swift                 # @Inject property wrapper – lazy, cached Locator lookup
├── Models/
│   ├── Character.swift              # Codable model mirroring the API JSON
│   ├── CharacterPage.swift          # Codable page wrapper ({ info, results })
│   └── RickAndMortyJSONDecoder.swift# JSONDecoder with the API's ISO-8601 (fractional-second) dates
├── Services/
│   ├── CharacterService.swift       # protocol CharacterService – the interface views depend on
│   ├── AppCharacterService.swift    # CharacterService backed by rickandmortyapi.com
│   ├── HTTPClient.swift             # protocol HTTPClient + URLSessionHTTPClient
│   └── APIError.swift               # LocalizedError cases raised by the service layer
├── Preview/
│   └── PreviewCharacterService.swift# Offline service + sample data for SwiftUI previews (DEBUG only)
├── ViewModels/
│   └── CharacterSearchViewModel.swift  # @Observable; debounces, cancels superseded searches
└── Views/
    ├── CharacterSearchView.swift    # Search bar + list + non-blocking progress indicator
    ├── CharacterRowView.swift       # Image (tappable), name, species
    └── CharacterDetailView.swift    # Name, full-width image, species, status, origin, type?, created
```

### Dependency injection

Dependencies are described by the `DependencyProvider` protocol and registered in a
`Locator` — a small, thread-safe service registry keyed by type:

```swift
protocol DependencyProvider {
    var characterService: CharacterService { get }
}

// App start-up
AppDependencyProvider().provide(locator: .shared)
```

`provide(locator:)` supplies each dependency to the locator as a `@Sendable` closure.
Consumers then declare what they need with the `@Inject` property wrapper, which resolves
from `Locator.shared` on first access and caches the result:

```swift
@Inject private var characterService: CharacterService
```

`@Inject` keeps its cache in a lock-guarded reference type, so it works on `let`
properties and inside a SwiftUI `body`, and concurrent first accesses resolve exactly once.
`Locator` and `Inject` are free of actor isolation; suppliers and resolved values must be
`Sendable` because they may cross isolation domains. Resolving a type that has no supplier
is a programmer error and traps with a clear message.

Below the composition root, everything still depends on protocols received through
initializers (`CharacterSearchViewModel(service:)`, `AppCharacterService(client:)`),
so units can be constructed with mocks directly, without touching the locator.

### Other notes

* **Service behind a protocol** – `CharacterService` (in its own file) is the interface the
  rest of the app depends on. `AppCharacterService` is the production implementation; it
  issues `GET https://rickandmortyapi.com/api/character/?name=<query>` through an injected
  `HTTPClient`. The API's `404 {"error": "There is nothing here"}` for zero matches is mapped
  to an empty array rather than an error.
* **JSON** – Plain `Codable` synthesis via `JSONDecoder`; only the date strategy is customised.
* **Search** – Each change to the search text cancels the in-flight request and schedules a new
  one (300 ms debounce). Results are applied only if the request was not superseded, so a slow
  earlier response can never overwrite a newer one. A "Searching…" banner is pinned under the
  search bar from the first keystroke until the response arrives; the list and search field
  stay interactive.
* **Previews** – `PreviewCharacterService` serves canned data so the SwiftUI canvas never
  hits the network.

## Tests

`RickAndMortyTests` uses **Swift Testing** (`@Test`, `#expect`, parameterised tests, traits):

* `CharacterDecodingTests` – decoding the real API shape, fractional-second dates, `hasType`.
* `AppCharacterServiceTests` – URL construction/encoding, 200/404/500 handling,
  malformed JSON (via `MockHTTPClient`).
* `CharacterSearchViewModelTests` – search-on-change, initial load, latest-search-wins
  cancellation, loading state, error state (via `MockCharacterService`).

### Mocks

* `MockDependencyProvider` – a `DependencyProvider` that supplies mocks.
* `.mockDependencies` – a Swift Testing trait (`MockDependenciesTrait`) applied to each suite.
  It registers `MockDependencyProvider` with `Locator.shared` exactly once, so anything using
  `@Inject` resolves mocks instead of live services.
* `MockCharacterService` – scriptable with a fluent API:

  ```swift
  MockCharacterService().returning(characters)
  MockCharacterService().throwing(APIError.httpStatus(503))
  MockCharacterService().handling { name in /* vary result by name */ }
  ```

* `MockHTTPClient` – records requests and returns a canned `(Data, statusCode)` or error.

Run from Xcode (⌘U) or:

```bash
xcodebuild test -project RickAndMorty.xcodeproj -scheme RickAndMorty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```
