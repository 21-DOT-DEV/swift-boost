//
//  BoostTests.swift
//  21-DOT-DEV/swift-boost
//
//  Copyright (c) 2026 Timechain Software Initiative, Inc.
//  Distributed under the MIT software license
//
//  See the accompanying file LICENSE for information
//

import Testing
import BoostTestHelpers

@Suite("Boost C++ Interop Tests")
struct BoostTests {

    @Test("boost::algorithm::clamp constrains value to range")
    func algorithmClamp() {
        #expect(boost_clamp(15, 0, 10) == 10)
        #expect(boost_clamp(5, 0, 10) == 5)
        #expect(boost_clamp(-5, 0, 10) == 0)
    }

    @Test("boost::optional holds and retrieves a value")
    func optionalValue() {
        let opt = BoostOptionalInt(42)
        #expect(opt.has_value())
        #expect(boost_optional_value(opt) == 42)
    }

    @Test("boost::variant reports correct active type index")
    func variantWhich() {
        #expect(boost_variant_which(CInt(7)) == 0)
        #expect(boost_variant_which(3.14) == 1)
    }
}
