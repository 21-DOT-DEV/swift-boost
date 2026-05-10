// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let boostModules: [String] = [
    "algorithm", "array", "assert", "bind", "concept_check", "config",
    "container", "container_hash", "core", "date_time", "describe", "detail",
    "foreach", "function", "integer", "io", "iterator", "lexical_cast",
    "move", "mp11", "mpl", "multi_index", "numeric_conversion", "optional",
    "preprocessor", "range", "serialization", "signals2", "smart_ptr",
    "static_assert", "throw_exception", "tokenizer", "tuple", "type_index",
    "type_traits", "utility", "variant",
]

/// Modules omitted from the `boost` umbrella's default dependency set.
///
/// Each module listed here is still published as an individual product
/// (and remains a buildable `.target`), so consumers that explicitly
/// depend on `.product(name: "<module>", package: "swift-boost")` are
/// unaffected. Only the convenience `boost` umbrella's transitive
/// surface shrinks, keeping `-I` and dependency-resolution cost down
/// for consumers that import it.
///
/// Modules are listed here when no other module in the umbrella's
/// transitive closure includes them, *and* their behavior is opt-in
/// at the consumer level (e.g. `serialization` is gated behind
/// `BOOST_MULTI_INDEX_DISABLE_SERIALIZATION` on the consumer side).
let pruneCandidates: Set<String> = [
    "algorithm", "array", "concept_check", "container", "date_time",
    "foreach", "io", "lexical_cast", "numeric_conversion", "range",
    "serialization", "tokenizer",
]

let boostIncludePaths: (String) -> [CXXSetting] = { prefix in
    boostModules.map { .headerSearchPath("\(prefix)\($0)/include") }
}

let package = Package(
    name: "Boost",
    products: boostModules.map { .library(name: $0, targets: [$0]) }
        + [.library(name: "boost", targets: ["boost"])],
    dependencies: [
        .package(url: "https://github.com/21-DOT-DEV/swift-plugin-subtree.git", exact: "0.0.12")
    ],
    targets: boostModules.map { .target(name: $0) } + [
        .target(
            name: "boost",
            dependencies: boostModules
                .filter { !pruneCandidates.contains($0) }
                .map { .target(name: $0) }
        ),
        .target(name: "BoostTestHelpers", cxxSettings: boostIncludePaths("../")),
        .testTarget(
            name: "BoostTests",
            dependencies: ["BoostTestHelpers"],
            cxxSettings: boostIncludePaths("../../Sources/"),
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ],
    cxxLanguageStandard: .cxx17
)
