#pragma once

// Includes one canonical header from every Boost module shipped by
// swift-boost. If a future module is added with a broken stub modulemap
// or a missing -I path, the build of this target will fail before any
// downstream consumer (e.g. swift-bitcoin) ever sees the regression.
//
// Note on `container`: the full container types (vector, map, etc.)
// transitively #include boost/intrusive, which swift-boost does not
// currently ship. We use container_fwd.hpp here so the probe still
// proves the container module's -I path is reachable; using the heavy
// containers requires adding the intrusive module to swift-boost.

#include <boost/algorithm/algorithm.hpp>           // algorithm
#include <boost/array.hpp>                         // array
#include <boost/assert.hpp>                        // assert
#include <boost/bind.hpp>                          // bind
#include <boost/concept_check.hpp>                 // concept_check
#include <boost/config.hpp>                        // config
#include <boost/container/container_fwd.hpp>       // container (see note below)
#include <boost/container_hash/hash.hpp>           // container_hash
#include <boost/core/noncopyable.hpp>              // core
#include <boost/date_time.hpp>                     // date_time
#include <boost/describe.hpp>                      // describe
#include <boost/blank.hpp>                         // detail
#include <boost/foreach.hpp>                       // foreach
#include <boost/function.hpp>                      // function
#include <boost/integer.hpp>                       // integer
#include <boost/io/ios_state.hpp>                  // io
#include <boost/iterator/iterator_facade.hpp>      // iterator
#include <boost/lexical_cast.hpp>                  // lexical_cast
#include <boost/move/move.hpp>                     // move
#include <boost/mp11.hpp>                          // mp11
#include <boost/mpl/vector.hpp>                    // mpl
#include <boost/multi_index_container.hpp>         // multi_index
#include <boost/numeric/conversion/cast.hpp>       // numeric_conversion
#include <boost/optional.hpp>                      // optional
#include <boost/preprocessor.hpp>                  // preprocessor
#include <boost/range.hpp>                         // range
#include <boost/serialization/serialization.hpp>   // serialization
#include <boost/signals2/signal.hpp>               // signals2
#include <boost/smart_ptr.hpp>                     // smart_ptr
#include <boost/static_assert.hpp>                 // static_assert
#include <boost/throw_exception.hpp>               // throw_exception
#include <boost/tokenizer.hpp>                     // tokenizer
#include <boost/tuple/tuple.hpp>                   // tuple
#include <boost/type_index.hpp>                    // type_index
#include <boost/type_traits.hpp>                   // type_traits
#include <boost/utility.hpp>                       // utility
#include <boost/variant.hpp>                       // variant
