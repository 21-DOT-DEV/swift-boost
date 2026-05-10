#pragma once

// Thin C++ shim used by the SwiftConsumer probe to verify swift-boost's
// per-target -I paths reach the clang importer that swiftc invokes during
// Swift/C++ interop builds in *external* packages. Mirrors the wrapping
// pattern documented in BoostTestHelpers — Boost templates rarely import
// directly into Swift.
#include <boost/algorithm/clamp.hpp>
#include <boost/optional.hpp>

using BoostOptionalInt = boost::optional<int>;

inline int boost_optional_value(const boost::optional<int> &opt) {
    return opt.get();
}

inline int boost_clamp(int value, int lo, int hi) {
    return boost::algorithm::clamp(value, lo, hi);
}
