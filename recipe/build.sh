#!/bin/bash

set -e
set -x
mkdir build
cd build

if [[ $(uname) = Darwin ]]; then
  # as we don't provide SDKs at a default location on OSX, we need to specify used
  # SDK location explicit and add clang option for it
  export CMAKE_OSX_SYSROOT="/opt/MacOSX10.14.sdk/"
  export CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} --sysroot /opt/MacOSX10.14.sdk/ -Wno-unknown-warning-option"
fi

cmake \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} \
    -DPYTHON_EXECUTABLE:FILEPATH=${PREFIX}/bin/python \
    -DPYTHON_INCLUDE_DIR=$(${PYTHON} -c 'import sysconfig; print(sysconfig.get_paths()["include"])') \
    -DPYTHON_LIBRARY=${PREFIX}/lib \
    ..
make -v -j ${CPU_COUNT}

${PYTHON} -m pip install --no-deps --ignore-installed ../
