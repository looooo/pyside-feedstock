#!/bin/sh

pushd sources/shiboken
mkdir build && cd build

export QTDIR=${PREFIX}

PY_LIB=`find $PREFIX/lib -name libpython${PY_VER}*${SHLIB_EXT}`
PY_INC=`find $PREFIX/include -name python${PY_VER}*`

cmake \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
  -DBUILD_TESTS=OFF \
  -DUSE_PYTHON3=${PY3K} \
  -DPYTHON3_INCLUDE_DIR=${PY_INC} \
  -DPYTHON3_LIBRARY=${PY_LIB} \
  ..
make install -j${CPU_COUNT}


popd
pushd sources/pyside
mkdir build && cd build

cmake \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  ..
make install -j${CPU_COUNT}

if test `uname` = "Darwin"
then
  # FIXME: restore phonon tests
  DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib ctest -j${CPU_COUNT} --output-on-failure --timeout 200 -E phonon
else
  # create a single X server connection rather than one for each test using the PySide USE_XVFB cmake option
  xvfb-run ctest -j${CPU_COUNT} --output-on-failure --timeout 200
fi

popd
pushd sources/pyside-tools
mkdir build && cd build

cmake \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTS=OFF \
  ..
make install -j${CPU_COUNT}
