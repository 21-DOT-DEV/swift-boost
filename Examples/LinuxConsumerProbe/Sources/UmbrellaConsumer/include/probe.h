#pragma once

// Public surface of this probe target. Putting the Boost #includes in the
// public header (rather than the .cpp) verifies -I propagation along the
// path a real downstream consumer would exercise: anything that depends on
// UmbrellaConsumer must be able to resolve Boost headers transitively.
#include <boost/multi_index_container.hpp>
#include <boost/multi_index/hashed_index.hpp>
#include <boost/multi_index/ordered_index.hpp>
#include <boost/signals2/signal.hpp>
#include <boost/operators.hpp>
#include <boost/tuple/tuple.hpp>

namespace probe_umbrella {
    using SignalT = boost::signals2::signal<void()>;
    using TupleT  = boost::tuple<int, int>;
}
