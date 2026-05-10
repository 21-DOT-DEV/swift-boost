# AGENTS.md (Examples/LinuxConsumerProbe)

This is a separate SPM package, NOT a target inside swift-boost. It depends on the parent package via `.package(path: "../..")` and exists to verify external-consumer behavior — particularly on Linux's `-fno-implicit-modules` default, where regressions in swift-boost's modulemaps would break downstream consumers like swift-bitcoin.

## Targets

- **`UmbrellaConsumer`** — depends on the `boost` umbrella product. `include/probe.h` includes a swift-bitcoin-representative subset of headers (`multi_index_container`, `signals2/signal`, `operators`, `tuple`, etc.).
- **`IndividualConsumer`** — depends on the swift-bitcoin-specific 27-module subset directly (no umbrella). Same header subset as `UmbrellaConsumer`. Catches regressions in per-product `-I` propagation along swift-bitcoin's actual usage path.
- **`AllModulesConsumer`** — depends on every individual product (all 37). `include/probe.h` includes one canonical header per module. Catches stub-modulemap regressions when a new module is added.
- **`SwiftConsumer`** + **`SwiftConsumerCxx`** — Swift target with `interoperabilityMode(.Cxx)` consuming a C++ shim that depends on `boost`. Mirrors swift-bitcoin's actual Swift→Boost path across a package boundary, which `Tests/BoostTests` can't cover from inside swift-boost itself.

## Non-obvious patterns

- **SPM package identity matches the parent directory name.** `dependencies: [.package(path: "../..")]` resolves the parent package's identity from the directory name (`swift-boost`). If the parent is checked out under a different directory name, `Package.swift`'s `.product(name: ..., package: "swift-boost")` references will fail to resolve. The Dockerfile's `WORKDIR` is set to `/swift-boost` for this reason.
- **`probe.h` carries the `#include`s, not `probe.cpp`.** Putting Boost includes in the public header proves `-I` paths reach downstream targets transitively — the path a real library consumer's public surface would exercise. Each `probe.cpp` is a one-liner that pulls the header in to force compilation.
- **`AllModulesConsumer` documents canonical-header choices.** Several Boost modules ship umbrella headers (`<boost/<mod>.hpp>`) that transitively `#include` modules swift-boost does NOT ship. The probe's `include/probe.h` documents the safe canonical header per module — comments call out each module name. When adding a new module, add its safe canonical header here.
- **`SwiftConsumerCxx` mirrors `BoostTestHelpers`** but lives in a separate package. The wrapping pattern (type aliases, thin functions) is identical — Swift cannot import Boost templates directly. The two files exist independently because `Tests/BoostTests` is internal to swift-boost; `SwiftConsumer` is the external-package equivalent.

## Known incomplete edges

- **`<boost/container/vector.hpp>` (and most full container types) cannot be reached** because they transitively `#include <boost/intrusive/...>`, which swift-boost does not ship. `AllModulesConsumer/include/probe.h` uses `<boost/container/container_fwd.hpp>` (forward declarations only). Fix: add `intrusive` as a module to `subtree.yaml` + `Package.swift`.
- **`<boost/signals2.hpp>` (umbrella header) pulls in `boost::parameter`**, which swift-boost does not ship. Use `<boost/signals2/signal.hpp>` (per-feature header) instead. The probes follow this convention.

## Workflow integration

- `Dockerfile` builds all four targets (`docker build .`).
- `.github/workflows/docker-builds.yml` runs the same Dockerfile in CI.
- `.github/workflows/apple-builds.yml`'s macOS job also builds the probe (`Build LinuxConsumerProbe (external-consumer regression coverage)` step) — exercises Apple-side external-consumer behavior, not just Linux.
