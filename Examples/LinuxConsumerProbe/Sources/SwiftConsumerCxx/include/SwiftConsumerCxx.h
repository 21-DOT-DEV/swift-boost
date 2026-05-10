#pragma once

// Thin C++ shim used by the SwiftConsumer probe to verify swift-boost's
// per-target -I paths reach the clang importer that swiftc invokes during
// Swift/C++ interop builds in *external* packages. Mirrors the wrapping
// pattern documented in BoostTestHelpers — Boost templates rarely import
// directly into Swift.
//
// Headers chosen to match modules that are present in the lean `boost`
// umbrella's transitive set so this consumer reflects what an
// umbrella-only downstream actually has on its include path.
#include <boost/optional.hpp>
#include <boost/tuple/tuple.hpp>

using BoostOptionalInt = boost::optional<int>;
using BoostIntTriple = boost::tuple<int, int, int>;

inline int boost_optional_value(const boost::optional<int> &opt) {
    return opt.get();
}

inline int boost_tuple_first(const BoostIntTriple &t) {
    return boost::get<0>(t);
}
