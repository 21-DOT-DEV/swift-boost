// swift-tools-version: 6.1
import PackageDescription

let umbrellaDeps: [Target.Dependency] = [
    .product(name: "boost", package: "swift-boost"),
]

// Mirrors swift-bitcoin's current production consumption pattern to provide
// regression coverage for the existing per-module API on Linux.
let swiftBitcoinModules: [String] = [
    "assert", "bind", "config", "container_hash", "core", "describe",
    "detail", "foreach", "function", "integer", "iterator", "move",
    "mp11", "mpl", "multi_index", "optional", "preprocessor",
    "serialization", "signals2", "smart_ptr", "static_assert",
    "throw_exception", "tuple", "type_index", "type_traits",
    "utility", "variant",
]

// Every module shipped by swift-boost. Keeping a target wired to the full
// list catches stub-modulemap regressions in any newly-subtree'd module
// before downstream consumers inherit them.
let allBoostModules: [String] = [
    "algorithm", "array", "assert", "bind", "concept_check", "config",
    "container", "container_hash", "core", "date_time", "describe", "detail",
    "foreach", "function", "integer", "io", "iterator", "lexical_cast",
    "move", "mp11", "mpl", "multi_index", "numeric_conversion", "optional",
    "preprocessor", "range", "serialization", "signals2", "smart_ptr",
    "static_assert", "throw_exception", "tokenizer", "tuple", "type_index",
    "type_traits", "utility", "variant",
]

let individualDeps: [Target.Dependency] = swiftBitcoinModules.map {
    .product(name: $0, package: "swift-boost")
}

let allModulesDeps: [Target.Dependency] = allBoostModules.map {
    .product(name: $0, package: "swift-boost")
}

let package = Package(
    name: "LinuxConsumerProbe",
    products: [
        .library(name: "UmbrellaConsumer", targets: ["UmbrellaConsumer"]),
        .library(name: "IndividualConsumer", targets: ["IndividualConsumer"]),
        .library(name: "AllModulesConsumer", targets: ["AllModulesConsumer"]),
        .library(name: "SwiftConsumer", targets: ["SwiftConsumer"]),
    ],
    dependencies: [.package(path: "../..")],
    targets: [
        .target(name: "UmbrellaConsumer", dependencies: umbrellaDeps),
        .target(name: "IndividualConsumer", dependencies: individualDeps),
        .target(name: "AllModulesConsumer", dependencies: allModulesDeps),
        .target(name: "SwiftConsumerCxx", dependencies: umbrellaDeps),
        .target(
            name: "SwiftConsumer",
            dependencies: ["SwiftConsumerCxx"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ],
    cxxLanguageStandard: .cxx17
)
