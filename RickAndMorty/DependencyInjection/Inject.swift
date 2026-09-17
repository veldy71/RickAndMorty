//
//  Inject.swift
//  RickAndMorty
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation

/// Resolves a dependency from `Locator` on first access, then caches it.
///
/// Usable from any isolation domain. The cache lives in a lock-guarded reference type
/// rather than in the wrapper's own storage, which buys two things: `wrappedValue` can
/// be `nonmutating` (so the wrapper works on `let` properties and inside a SwiftUI
/// `body`), and concurrent first accesses resolve exactly once.
@propertyWrapper
struct Inject<T: Sendable>: Sendable {

    /// Lock-guarded, lazily populated cache shared by all accesses to one `@Inject`.
    private final class Cache: @unchecked Sendable {
        private let lock = NSLock()
        private var value: T?

        /// Returns the cached value, resolving it from `Locator.shared` on first access.
        func resolve() -> T {
            lock.lock()
            defer { lock.unlock() }

            guard let value = value else {
                let resolved: T = Locator.shared.resolve()
                self.value = resolved
                return resolved
            }

            return value
        }

        /// Overwrites the cached value, bypassing the locator.
        func store(_ newValue: T) {
            lock.lock()
            defer { lock.unlock() }

            value = newValue
        }
    }

    private let cache = Cache()

    /// Creates a wrapper that resolves lazily from `Locator.shared` on first access.
    init() { }

    /// Seeds the cache directly, bypassing the `Locator`. Handy for tests and previews.
    init(wrappedValue: T) {
        cache.store(wrappedValue)
    }

    /// The injected dependency. Reading resolves (once) from `Locator.shared`; writing
    /// replaces the cached value without touching the locator.
    var wrappedValue: T {
        get {
            cache.resolve()
        }
        nonmutating set {
            cache.store(newValue)
        }
    }
}
