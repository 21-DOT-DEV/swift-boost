//
//  BoostTestHelpers.h
//  21-DOT-DEV/swift-boost
//
//  Copyright (c) 2026 Timechain Software Initiative, Inc.
//  Distributed under the MIT software license
//
//  See the accompanying file LICENSE for information
//

#pragma once

#include <boost/algorithm/clamp.hpp>
#include <boost/optional.hpp>
#include <boost/variant.hpp>

/// Type alias exposes boost::optional<int> to Swift as a value type.
/// See: https://www.swift.org/documentation/cxx-interop/#using-class-templates
using BoostOptionalInt = boost::optional<int>;

/// Thin wrapper: boost::optional accessors return references, which Swift
/// considers interior pointers and blocks by default.
inline int boost_optional_value(const boost::optional<int> &opt) {
    return opt.get();
}

/// Thin wrapper: Swift cannot call uninstantiated C++ function templates.
inline int boost_clamp(int value, int lo, int hi) {
    return boost::algorithm::clamp(value, lo, hi);
}

/// Thin wrapper: boost::variant uses heavy MPL metaprogramming that
/// exceeds the clang importer's template instantiation depth.
inline int boost_variant_which(int value) {
    boost::variant<int, double> v(value);
    return v.which();
}

inline int boost_variant_which(double value) {
    boost::variant<int, double> v(value);
    return v.which();
}
