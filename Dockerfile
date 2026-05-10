FROM swift:6.3
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git pkg-config && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /swift-boost
COPY . .
RUN swift --version

# swift-boost itself: build all targets and run BoostTests, which exercises
# Swift/C++ interop via BoostTestHelpers (clamp/optional/variant). The shipped
# `requires !cplusplus` modulemaps let Linux's -fno-implicit-modules default
# fall through to textual #include without any post-resolve injection.
RUN swift build
RUN swift test

# External-consumer probe: depends on swift-boost via local path. Exercises
# both the new `boost` umbrella product and the existing per-module products
# as a swift-bitcoin-style consumer would, catching regressions in either
# resolution path on Linux.
RUN cd Examples/LinuxConsumerProbe && swift build

CMD ["swift", "test"]
