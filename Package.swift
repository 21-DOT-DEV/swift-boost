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

let boostIncludePaths: (String) -> [CXXSetting] = { prefix in
    boostModules.map { .headerSearchPath("\(prefix)\($0)/include") }
}

let package = Package(
    name: "Boost",
    products: boostModules.map { .library(name: $0, targets: [$0]) },
    dependencies: [
        .package(url: "https://github.com/21-DOT-DEV/swift-plugin-subtree.git", exact: "0.0.12")
    ],
    targets: boostModules.map { .target(name: $0) } + [
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
