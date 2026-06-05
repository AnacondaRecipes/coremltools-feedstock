#!/bin/bash

set -e
set -x

export PREFIX=${PREFIX:-${CONDA_PREFIX}}

# Remove vendored protobuf so the system library from libprotobuf is used instead
# (kmeans1d is kept vendored since it is not available on pkgs/main)
rm -rf deps/protobuf

Protobuf_PROTOC_EXECUTABLE=${PREFIX}/bin/protoc

COMMON_CMAKE_ARGS=(
    ${CMAKE_ARGS}
    -DOVERWRITE_PB_SOURCE=ON
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    -DProtobuf_PROTOC_EXECUTABLE="${Protobuf_PROTOC_EXECUTABLE}"
    -DPython_FIND_STRATEGY:STRING=LOCATION
    -DPython_ROOT_DIR:FILEPATH="${PREFIX}"
)

rm -rf mlmodel/build
mkdir -p mlmodel/build/format

mkdir -p build
pushd build
cmake "${COMMON_CMAKE_ARGS[@]}" ..
# Generate protobuf sources first, then build the rest
cmake --build . --target protosrc
make -j "${CPU_COUNT}"
popd

${PYTHON:-python} -m pip install --no-deps --ignore-installed ./
