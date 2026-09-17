//
//  Locator.swift
//  RickAndMorty
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation

/// Service registry for dependencies that cannot be threaded through initializers.
///
/// Free of actor isolation, so registration and resolution work from any isolation
/// domain. The supplier table is guarded by a lock. Suppliers must be `@Sendable` and
/// produce `Sendable` values, because a resolved dependency can cross isolation
/// boundaries between the thread that registered it and the one that resolves it.
final class Locator: @unchecked Sendable {

    /// The process-wide registry used by `@Inject`.
    static let shared = Locator()

    private let lock = NSLock()
    /// Registered suppliers keyed by the `ObjectIdentifier` of the type they produce.
    private var suppliers: [ObjectIdentifier: @Sendable () -> any Sendable] = [:]

    private init() { }

    /// Registers `supplier` as the source for values of type `T`, replacing any
    /// previous supplier for that type.
    ///
    /// The supplier is invoked on every `resolve()`; callers that want a single
    /// shared instance should capture it outside the closure.
    /// - Parameter supplier: Produces a `T`. Must be `@Sendable` because it may be
    ///   invoked from any isolation domain.
    func supply<T: Sendable>(supplier: @escaping @Sendable () -> T) {
        lock.lock()
        defer { lock.unlock() }

        suppliers[ObjectIdentifier(T.self)] = supplier
    }

    /// Produces a value of type `T` from its registered supplier.
    ///
    /// The requested type is inferred from the call site, e.g.
    /// `let service: CharacterService = Locator.shared.resolve()`.
    /// - Returns: A freshly supplied `T`.
    /// - Precondition: A supplier for `T` has been registered via `supply(supplier:)`.
    ///   Resolving an unregistered type is a programmer error and traps.
    func resolve<T: Sendable>() -> T {
        // Look the supplier up under the lock, then invoke it outside the lock so a
        // supplier that resolves its own collaborators cannot deadlock the registry.
        lock.lock()
        let supplier = suppliers[ObjectIdentifier(T.self)]
        lock.unlock()

        guard let result = supplier?() as? T else {
            preconditionFailure("Failed to resolve \(T.self). A supplier is required for \(T.self).")
        }

        return result
    }
}
