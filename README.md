[![Apple Platforms](https://github.com/21-DOT-DEV/swift-boost/actions/workflows/apple-builds.yml/badge.svg)](https://github.com/21-DOT-DEV/swift-boost/actions/workflows/apple-builds.yml) [![Docker Builds](https://github.com/21-DOT-DEV/swift-boost/actions/workflows/docker-builds.yml/badge.svg)](https://github.com/21-DOT-DEV/swift-boost/actions/workflows/docker-builds.yml) [![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE) [![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F21-DOT-DEV%2Fswift-boost%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/21-DOT-DEV/swift-boost) [![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2F21-DOT-DEV%2Fswift-boost%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/21-DOT-DEV/swift-boost)

# 🚀 swift-boost

Vendored [Boost](https://www.boost.org/) 1.90.0 C++ header-only modules for Swift packages. Uses Swift's [C++ interoperability](https://www.swift.org/documentation/cxx-interop/) to make Boost headers available to Swift targets.

```swift
.package(url: "https://github.com/21-DOT-DEV/swift-boost.git", exact: "1.90.0"),
```

## Why swift-boost?

Reach for `swift-boost` when you need a wide cross-section of header-only Boost in a SwiftPM-native form across Apple platforms and Linux — for example, Bitcoin Core ports like [swift-bitcoin](https://github.com/21-DOT-DEV/swift-bitcoin) that consume `multi_index`, `signals2`, `mp11`, and dozens of other modules. The 37 modules ship as individual library products plus a `boost` umbrella, so you don't have to subtree Boost into your own package or hand-write per-module SPM wiring.

Don't reach for it if you only need one or two header-only Boost modules — subtree-ing them directly into your own package is simpler and avoids taking a dependency. And if your goal is portable C++ standard-library functionality, modern C++17/20 (`std::variant`, `std::optional`, `std::filesystem`) covers a lot of what Boost historically provided without any vendored dependency.

## Contents

- [Features](#features)
- [Available Modules](#available-modules)
- [Installation](#installation)
- [Versioning](#versioning)
- [Usage](#usage)
- [Development](#development)
- [Contributing](#contributing)
- [Security](#security)
- [License](#license)

## Features

- **37 Boost modules** as individual SwiftPM library products, plus a `boost` umbrella product mirroring upstream Boost's CMake `Boost::headers` target
- **Swift/C++ interop ready** — pair with a C++ bridging header to call Boost from Swift via `interoperabilityMode(.Cxx)`
- **Apple platforms + Linux** — macOS 13+, iOS, visionOS, and Ubuntu 22.04+ (Swift 6.1+, C++17)
- **Header-only** — no Boost source compilation; ships only public headers
- **Linux-native modulemaps** — ships `requires !cplusplus` modulemap stubs so consumers don't need post-resolve workarounds for Swift's `-fno-implicit-modules` default

## Available Modules

Each Boost module is exposed as an individual SwiftPM library product.

| Category | Modules |
|----------|--------|
| Algorithms & Ranges | `algorithm`, `foreach`, `iterator`, `range` |
| Containers | `array`, `container`, `multi_index`, `variant`, `optional`, `tuple` |
| Memory & Pointers | `smart_ptr`, `move` |
| Metaprogramming | `mp11`, `mpl`, `preprocessor`, `type_traits`, `type_index` |
| Serialization & I/O | `serialization`, `lexical_cast`, `io` |
| Signals & Events | `signals2` |
| Utilities | `bind`, `config`, `core`, `describe`, `function`, `utility` |

See [`Package.swift`](Package.swift) for the complete list of all 37 modules.

A `boost` umbrella product is also available, mirroring upstream Boost's CMake `Boost::headers` target. Depending on `boost` brings in every module's headers transitively, which is convenient for consumers (such as Bitcoin Core ports) that use a wide cross-section of Boost.

## Installation

This package uses Swift Package Manager.

### Using Xcode

1. Go to `File > Add Packages...`
2. Enter the package URL: `https://github.com/21-DOT-DEV/swift-boost`
3. Select the desired version (recommend pinning to an exact version — see [Versioning](#versioning))

### Using Package.swift (Recommended)

Add the following to your `Package.swift`:

```swift
.package(url: "https://github.com/21-DOT-DEV/swift-boost.git", exact: "1.90.0"),
```

> [!NOTE]
> swift-boost tags mirror upstream Boost releases. Pin with `exact:` because Boost minor releases can deprecate or remove modules. See [Versioning](#versioning) below.

Then add the Boost modules you need as dependencies and enable C++ interop on the consuming target:

```swift
.target(
    name: "MyTarget",
    dependencies: [
        .product(name: "algorithm", package: "swift-boost"),
        .product(name: "optional", package: "swift-boost"),
    ],
    swiftSettings: [
        .interoperabilityMode(.Cxx),
    ]
),
```

For consumers using a wide cross-section of Boost, depend on the umbrella product instead:

```swift
.target(
    name: "MyTarget",
    dependencies: [
        .product(name: "boost", package: "swift-boost"),
    ],
    swiftSettings: [
        .interoperabilityMode(.Cxx),
    ]
),
```

Set `cxxLanguageStandard: .cxx17` (or higher) at the package level.

## Versioning

swift-boost tags mirror upstream Boost releases. Recent tags:

| Tag | Boost upstream |
|---|---|
| `1.90.0` | Boost 1.90.0 |
| `1.81.0` | Boost 1.81.0 |
| `1.80.0` | Boost 1.80.0 |

> [!NOTE]
> Boost minor releases can deprecate or remove modules. Pin consumers with `exact:` so you choose explicitly when to take on Boost upstream changes — `from:` would auto-uptake new Boost releases and expose your package to module-surface churn.

The `subtree-1.81.0` tag in the repository's tag list is a one-off subtree-migration milestone, not a Boost release; ignore it for normal version selection.

## Usage

> [!NOTE]
> This package provides C++ headers, not Swift wrapper APIs. To use Boost types from Swift, you need a C++ bridging header with explicit type aliases and thin wrappers. This is a requirement of Swift/C++ interop — not all C++ patterns import directly into Swift.

### C++ Bridging Header

Create a C++ header that instantiates the Boost templates you need:

```cpp
#pragma once

#include <boost/algorithm/clamp.hpp>
#include <boost/optional.hpp>

// Expose a concrete template instantiation to Swift
using BoostOptionalInt = boost::optional<int>;

// Thin wrapper: Swift cannot call uninstantiated C++ function templates
inline int boost_clamp(int value, int lo, int hi) {
    return boost::algorithm::clamp(value, lo, hi);
}

// Thin wrapper: boost::optional accessors return references,
// which Swift considers interior pointers and blocks by default
inline int boost_optional_value(const boost::optional<int> &opt) {
    return opt.get();
}
```

### Swift Consumer

```swift
import MyBridgingModule

let clamped = boost_clamp(15, 0, 10)  // 10

let opt = BoostOptionalInt(42)
let value = boost_optional_value(opt)  // 42
```

> [!NOTE]
> For more detail on Swift/C++ interop patterns (type aliases for class templates, wrapping function templates, interior pointer limitations), see the [Swift C++ Interop documentation](https://www.swift.org/documentation/cxx-interop/). For a working external-consumer example, see [`Examples/LinuxConsumerProbe`](Examples/LinuxConsumerProbe).

## Development

### Requirements

- Swift 6.1+
- C++17
- macOS 13+ or Linux

### Linux build verification

```bash
docker build .
```

The included [`Dockerfile`](Dockerfile) builds and tests the package on `swift:6.3`, then builds [`Examples/LinuxConsumerProbe`](Examples/LinuxConsumerProbe) — an external-consumer smoke test that exercises the `boost` umbrella, the per-module products, all 37 modules in one translation unit, and a Swift target consuming Boost via C++ interop across a package boundary.

## Contributing

Contributions are welcome. Read the [21-DOT-DEV contributing guidelines](https://github.com/21-DOT-DEV/.github/blob/main/CONTRIBUTING.md) for general workflow, and [AGENTS.md](AGENTS.md) for project-specific architecture notes (modulemap stubs, subtree extraction flow, adding a new Boost module).

## Security

For information on reporting security vulnerabilities, see the [21-DOT-DEV SECURITY.md](https://github.com/21-DOT-DEV/.github/blob/main/SECURITY.md).

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.

Boost libraries are distributed under the [Boost Software License 1.0](https://www.boost.org/LICENSE_1_0.txt).
