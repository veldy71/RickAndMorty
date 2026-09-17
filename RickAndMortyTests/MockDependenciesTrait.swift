//
//  MockDependenciesTrait.swift
//  RickAndMortyTests
//
//  Created by Thomas Veldhouse on 9/17/26.
//

import Foundation
import Testing
@testable import RickAndMorty

/// Registers the mock dependencies with `Locator.shared` so `@Inject` resolves
/// test doubles instead of live services.
///
/// Swift Testing has no per-bundle launch hook, so registration hangs off a trait
/// that suites adopt. `prepare(for:)` runs once per annotated test — potentially
/// in parallel — so the registration itself is a one-shot `static let`, which
/// Swift guarantees to initialize exactly once.
struct MockDependenciesTrait: SuiteTrait, TestTrait {
    /// Applies to every test and sub-suite inside an annotated suite.
    var isRecursive: Bool { true }

    /// One-shot registration. Swift initializes a `static let` exactly once, even
    /// when first touched concurrently from parallel tests.
    private static let registered: Void = {
        MockDependencyProvider().provide(locator: .shared)
    }()

    /// Ensures the mocks are registered before `test` runs.
    func prepare(for test: Test) async throws {
        Self.registered
    }
}

extension Trait where Self == MockDependenciesTrait {
    /// Supplies the mock dependencies to `Locator.shared` before the test runs.
    static var mockDependencies: Self { Self() }
}
