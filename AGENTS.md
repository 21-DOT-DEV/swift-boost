# AGENTS.md (swift-boost)

A header-aggregator SwiftPM package vendoring [Boost](https://www.boost.org/) 1.90.0 C++ headers as 37 individual library products plus a `boost` umbrella product. Supports macOS 13+ and Linux (Ubuntu 22.04+). Uses C++17 (`cxxLanguageStandard: .cxx17`) and is consumed via Swift's [C++ interoperability](https://www.swift.org/documentation/cxx-interop/) (`interoperabilityMode(.Cxx)`).

## Commands

- Build: `swift build`
- Test: `swift test`
- Linux verify: `docker build .` (builds + tests on `swift:6.3`, then builds `Examples/LinuxConsumerProbe`)
- Probe build (any platform): `cd Examples/LinuxConsumerProbe && swift build`

## Non-obvious patterns

- **Stub modulemaps for Linux**: every `Sources/<module>/include/module.modulemap` declares an empty module with `requires !cplusplus`. On Linux, Swift defaults to `-fno-implicit-modules` while C++ interop forces `-fmodules`; without a modulemap, the build fails with "module needed but not provided." The `requires !cplusplus` clause makes the modulemap not match any C++ TU, falling through to textual `#include`. Without these stubs shipped in the package, downstream consumers like swift-bitcoin need a post-resolve workaround that injects them after `swift package resolve`.
- **Two consumption patterns**: per-module products (`assert`, `optional`, `multi_index`, ...) for fine-grained control, plus a `boost` umbrella product whose target depends on every module. Consumers using a wide cross-section (e.g. Bitcoin Core ports) prefer the umbrella; consumers needing only one or two modules use them individually.
- **Header-only with stub `.cpp`**: SPM requires at least one source file per target. Each module has a near-empty `<module>.cpp` under `Sources/<module>/src/` that exists only to satisfy SPM. No Boost source is compiled. `Sources/boost/src/boost.cpp` plays the same role for the umbrella.
- **Extraction flow**: `subtree.yaml` is the source of truth for which Boost modules are vendored and at which upstream tag. The [`swift-plugin-subtree`](https://github.com/21-DOT-DEV/swift-plugin-subtree) plugin extracts headers via `git subtree`. Do NOT edit `Sources/<module>/include/boost/**` directly — those paths are overwritten on the next extraction.
- **`container` is incomplete**: `boost::container` (vector, map, etc.) transitively requires `boost::intrusive`, which is not currently shipped. The module's `-I` path is reachable but the full container types fail to compile. Use `<boost/container/container_fwd.hpp>` (forward decls only) for now. Fix is to subtree `intrusive` into `subtree.yaml` + add it to `Package.swift`.
- **Boost umbrella headers can pull in unshipped modules**: `<boost/signals2.hpp>` pulls `boost::parameter` (not shipped). Per-feature headers like `<boost/signals2/signal.hpp>` are the right choice. `Examples/LinuxConsumerProbe/Sources/AllModulesConsumer/include/probe.h` documents the canonical-header choice per module.
- **Versioning mirrors upstream Boost**: tags follow Boost releases (`1.80.0`, `1.81.0`, `1.90.0`). The `subtree-1.81.0` tag was a one-off subtree-migration milestone, not a Boost release. Recommend consumers pin with `exact:` because Boost minor releases can deprecate or remove modules.

## External-consumer regression coverage

`Examples/LinuxConsumerProbe` is a separate SPM package that depends on swift-boost via `path: "../.."`. It builds four target shapes mirroring real downstream consumption:

- `UmbrellaConsumer` — depends on `boost`; uses a swift-bitcoin-representative header subset.
- `IndividualConsumer` — depends on the swift-bitcoin-specific 27-module subset; same header subset.
- `AllModulesConsumer` — depends on every individual product with one canonical header per module. Catches regressions when a new module is added with a broken stub modulemap.
- `SwiftConsumer` + `SwiftConsumerCxx` — Swift target with `interoperabilityMode(.Cxx)` consuming a C++ shim that depends on `boost`. Mirrors swift-bitcoin's actual Swift→Boost path across a package boundary.

The Dockerfile builds all four; `.github/workflows/docker-builds.yml` runs the same Dockerfile in CI, and `apple-builds.yml`'s macOS job also builds the probe.

## Adding a new Boost module

1. Add the upstream subtree entry to `subtree.yaml`.
2. Run the SubtreePlugin to materialize headers under `Sources/<module>/include/boost/`.
3. Create `Sources/<module>/include/module.modulemap` matching existing stubs (`module <name>_modulemap_stub { requires !cplusplus }`).
4. Add the module name to `boostModules` in `Package.swift`.
5. Add a canonical header for the module to `Examples/LinuxConsumerProbe/Sources/AllModulesConsumer/include/probe.h` so future modulemap regressions surface in CI.
6. Verify: `swift build && swift test && docker build .`.

## Boundaries

- **Never**: edit `Sources/<module>/include/boost/**` directly (overwritten on next subtree extraction); replace `requires !cplusplus` modulemaps with concrete `header` declarations (would re-break Linux's `-fno-implicit-modules`); broaden GitHub Actions `permissions` without justification.
- **Ask first**: add a new Boost module not in `subtree.yaml`; modify the `boostModules` list in `Package.swift` without a corresponding `subtree.yaml` change; alter the `boost` umbrella's dependency list.
- See the [21-DOT-DEV contributing guidelines](https://github.com/21-DOT-DEV/.github/blob/main/CONTRIBUTING.md) for branching and commit guidelines. See the [21-DOT-DEV SECURITY.md](https://github.com/21-DOT-DEV/.github/blob/main/SECURITY.md) for vulnerability reporting.

## Scoped guidance

Directory-specific `AGENTS.md` files provide additional context:

- [`Sources/AGENTS.md`](Sources/AGENTS.md) — per-module structure, modulemap stubs, BoostTestHelpers carve-out, adding-a-module workflow
- [`Examples/LinuxConsumerProbe/AGENTS.md`](Examples/LinuxConsumerProbe/AGENTS.md) — probe targets, SPM package-identity caveat, known incomplete edges (`container`/`intrusive`, `signals2` umbrella)

## Maintenance

- Update when build/test workflows, Boost version, platform support, or shipped modules change.
- The "Non-obvious patterns" section is the most load-bearing — keep it current with caveats discovered in real consumer integrations.
