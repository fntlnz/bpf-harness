#
# Copyright (C) 2021 The Falco Authors
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
#

option(USE_BUNDLED_ZLIB "Enable building of the bundled zlib" ${USE_BUNDLED_DEPS})

if (NOT USE_BUNDLED_ZLIB)
  find_path(ZLIB_INCLUDE zlib.h PATH_SUFFIXES zlib)
  if (NOT BUILD_STATIC)
    find_library(ZLIB_LIB NAMES z)
  else ()
    find_library(ZLIB_LIB NAMES libz.a)
  endif ()
  if (ZLIB_INCLUDE AND ZLIB_LIB)
    message(STATUS "Found zlib: include: ${ZLIB_INCLUDE}, lib: ${ZLIB_LIB}")
  else ()
    message(FATAL_ERROR "Couldn't find system zlib")
  endif ()
  set(ZLIB_PKGCONFIG "") # nothing to add, already in system

else ()
  set(ZLIB_SRC "${PROJECT_BINARY_DIR}/zlib-prefix/src/zlib")
  set(ZLIB_BUILD "${PROJECT_BINARY_DIR}/zlib-prefix/src/zlib-build")
  set(ZLIB_PKGCONFIG "${PROJECT_BINARY_DIR}/zlib-prefix/src/zlib-build/lib/pkgconfig")
  message(STATUS "Using bundled zlib in '${ZLIB_SRC}'")
  set(ZLIB_INCLUDE "${ZLIB_SRC}")
  set(ZLIB_LIB "${ZLIB_SRC}/libz.a")
  ExternalProject_Add(zlib
    URL "https://github.com/madler/zlib/archive/v1.2.11.tar.gz"
    URL_HASH "SHA256=629380c90a77b964d896ed37163f5c3a34f6e6d897311f1df2a7016355c45eff"
    CONFIGURE_COMMAND ./configure --prefix=${ZLIB_BUILD}
    BUILD_COMMAND make
    BUILD_IN_SOURCE 1
    BUILD_BYPRODUCTS ${ZLIB_LIB}
    INSTALL_COMMAND make install)

endif ()