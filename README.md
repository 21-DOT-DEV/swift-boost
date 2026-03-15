[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

# swift-boost

Vendored [Boost](https://www.boost.org/) 1.90.0 C++ header-only modules for Swift packages. Uses Swift's [C++ interoperability](https://www.swift.org/documentation/cxx-interop/) to make Boost headers available to Swift targets.

## Contents

- [Features](#features)
- [Available Modules](#available-modules)
- [Installation](#installation)
- [Usage](#usage)
- [Development](#development)
- [License](#license)

## Features

- Provide 37 Boost C++ header-only modules as individual SwiftPM library products
- Enable Swift/C++ interop consumption of Boost types and algorithms
- Support macOS and Linux (Swift 6.1+, C++17)
- Extract only public headers — no Boost source compilation required

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

## Installation

This package uses Swift Package Manager. To add it to your project:

### Using Xcode

1. Go to `File > Add Packages...`
2. Enter the package URL: `https://github.com/21-DOT-DEV/swift-boost`
3. Select the desired version

### Using Package.swift (Recommended)

Add the following to your `Package.swift` file:

```swift
.package(url: "https://github.com/21-DOT-DEV/swift-boost.git", from: "0.1.0"),
```

Then, add the Boost modules you need as dependencies and enable C++ interop:

```swift
.target(
    name: "MyTarget",
    dependencies: [
        .product(name: "algorithm", package: "swift-boost"),
        .product(name: "optional", package: "swift-boost"),
    ],
    cxxSettings: [
        .headerSearchPath("path/to/boost/module/include"),
    ],
    swiftSettings: [
        .interoperabilityMode(.Cxx),
    ]
),
```

## Usage

> [!NOTE]
> This package provides C++ headers, not Swift wrapper APIs. To use Boost types from Swift, you need a C++ bridging header with explicit type aliases and thin wrappers. This is a requirement of Swift/C++ interop — not all C++ patterns import directly.

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
> For more details on Swift/C++ interop patterns (type aliases for class templates, wrapping function templates, interior pointer limitations), see [Swift C++ Interop documentation](https://www.swift.org/documentation/cxx-interop/).

## Development

### Requirements

- Swift 6.1+
- C++17
- macOS 13+ or Linux

### Project Structure

```
Sources/
├── algorithm/          # Boost.Algorithm headers (include/boost/algorithm/)
├── optional/           # Boost.Optional headers (include/boost/optional/)
├── variant/            # Boost.Variant headers (include/boost/variant/)
├── ...                 # 34 more Boost modules
└── BoostTestHelpers/   # C++ bridging header for tests
```

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.

Boost libraries are distributed under the [Boost Software License 1.0](https://www.boost.org/LICENSE_1_0.txt).
