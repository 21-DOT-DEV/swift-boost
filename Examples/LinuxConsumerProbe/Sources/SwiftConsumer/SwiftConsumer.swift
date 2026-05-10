import SwiftConsumerCxx

// Swift external-consumer probe. Importing SwiftConsumerCxx (which itself
// depends on the `boost` umbrella) verifies that swift-boost's -I paths
// reach swiftc's clang importer across a package boundary — the path
// downstream consumers actually exercise and that BoostTests cannot
// cover from inside swift-boost itself.
public enum SwiftConsumer {

    public static func optional(_ value: CInt) -> CInt {
        let opt = BoostOptionalInt(value)
        return boost_optional_value(opt)
    }

    public static func tupleFirst(_ a: CInt, _ b: CInt, _ c: CInt) -> CInt {
        let triple = BoostIntTriple(a, b, c)
        return boost_tuple_first(triple)
    }
}
