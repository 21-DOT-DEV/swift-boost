# AGENTS.md (Sources)

This directory contains the 37 Boost module targets, the `boost` umbrella target, and `BoostTestHelpers` (the C++ shim used by `Tests/BoostTests`).

## What lives here

- **37 Boost module targets**: `algorithm/`, `array/`, `assert/`, `bind/`, `concept_check/`, `config/`, `container/`, `container_hash/`, `core/`, `date_time/`, `describe/`, `detail/`, `foreach/`, `function/`, `integer/`, `io/`, `iterator/`, `lexical_cast/`, `move/`, `mp11/`, `mpl/`, `multi_index/`, `numeric_conversion/`, `optional/`, `preprocessor/`, `range/`, `serialization/`, `signals2/`, `smart_ptr/`, `static_assert/`, `throw_exception/`, `tokenizer/`, `tuple/`, `type_index/`, `type_traits/`, `utility/`, `variant/` — each is one Boost upstream module's headers.
- **`boost/`**: umbrella target whose `Package.swift` declaration depends on every module above. Provides the `boost` library product.
- **`BoostTestHelpers/`**: NOT one of the 37 modules. C++ shim that wraps Boost templates into Swift-importable signatures (type aliases, thin functions). Used only by `Tests/BoostTests`.

## Per-module structure

Every Boost module target is laid out as:

```
Sources/<module>/
├── include/
│   ├── boost/                     # extracted upstream headers (DO NOT EDIT)
│   │   └── <upstream layout>/
│   └── module.modulemap           # stub: `requires !cplusplus`
└── src/
    └── <module>.cpp               # SPM-appeasement stub
```

The umbrella `Sources/boost/` follows the same shape (`include/module.modulemap` + `src/boost.cpp`).

## Non-obvious patterns

- **`include/boost/**` is extracted, not authored.** `subtree.yaml` declares the upstream Boost repo + tag for each module; the `swift-plugin-subtree` plugin populates `include/boost/...` via `git subtree`. Hand edits in this subtree are overwritten on the next extraction.
- **`include/module.modulemap` is the Linux fix.** The stub declares `module <name>_modulemap_stub { requires !cplusplus }` — it never matches a C++ TU, so the build falls through to textual `#include`. Without this, Linux's `-fno-implicit-modules` default fails when Swift/C++ interop forces `-fmodules`. Do NOT replace the `requires !cplusplus` with concrete `header` declarations — it would re-break Linux for downstream consumers.
- **`src/<module>.cpp` exists only to satisfy SPM.** SPM requires at least one source file per target; Boost compiles nothing. The `.cpp` files are near-empty and flagged `linguist-generated` in `.gitattributes` so GitHub doesn't count them as authored code.
- **The `boost` umbrella has no extracted headers.** Its `include/boost/` is intentionally absent — the umbrella exists purely for transitive `-I` propagation via its dependency list in `Package.swift`.
- **`BoostTestHelpers` is the cxx-interop shim.** Boost templates often don't import directly to Swift (function templates need explicit instantiation; reference returns are interior pointers; heavy MPL exceeds clang importer template depth). `BoostTestHelpers/include/BoostTestHelpers.h` wraps these into Swift-callable signatures. Mirror this pattern when adding tests.

## Adding a new Boost module

1. Add an entry to `subtree.yaml` (path: `Sources/<module>`, repo, tag).
2. Run the SubtreePlugin to extract upstream headers under `Sources/<module>/include/boost/`.
3. Create `Sources/<module>/include/module.modulemap` matching existing stubs (`module <name>_modulemap_stub { requires !cplusplus }`).
4. Create `Sources/<module>/src/<module>.cpp` (one-line comment is fine).
5. Add the module name to `boostModules` in `Package.swift`.
6. Add a canonical header to `Examples/LinuxConsumerProbe/Sources/AllModulesConsumer/include/probe.h`.
