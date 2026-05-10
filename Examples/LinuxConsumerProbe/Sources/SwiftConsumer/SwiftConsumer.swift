import SwiftConsumerCxx

// Swift external-consumer probe. Importing SwiftConsumerCxx (which itself
// depends on the `boost` umbrella) verifies that swift-boost's -I paths
// reach swiftc's clang importer across a package boundary — the path
// swift-bitcoin actually exercises and that BoostTests cannot cover from
// inside swift-boost itself.
public enum SwiftConsumer {

    public static func clamp(_ value: CInt, lo: CInt, hi: CInt) -> CInt {
        boost_clamp(value, lo, hi)
    }

    public static func optional(_ value: CInt) -> CInt {
        let opt = BoostOptionalInt(value)
        return boost_optional_value(opt)
    }
}
