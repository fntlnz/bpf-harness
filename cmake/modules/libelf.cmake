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

option(USE_BUNDLED_LIBELF "Enable building of the bundled libelf" ${USE_BUNDLED_DEPS})

if (NOT USE_BUNDLED_LIBELF)
  find_path(LIBELF_INCLUDE gelf.h PATH_SUFFIXES libelf)
  if (NOT BUILD_STATIC)
    find_library(LIBELF_LIB NAMES elf)
  else ()
    find_library(LIBELF_LIB NAMES libelf.a)
  endif ()
  set(LIBELF_PKGCONFIG "") # nothing to add, already in system

  if (LIBELF_LIB AND LIBELF_INCLUDE)
    message(STATUS "Found libelf: include: ${LIBELF_INCLUDE}, lib: ${LIBELF_LIB}")
  else ()
    message(FATAL_ERROR "Couldn't find system libelf")
  endif ()

else ()
  set(LIBELF_SRC "${CMAKE_CURRENT_BINARY_DIR}/libelf-prefix/src")
  set(LIBELF_BUILD_DIR "${LIBELF_SRC}/libelf-build")
  set(LIBELF_INCLUDE "${LIBELF_BUILD_DIR}/include")
  set(LIBELF_LIB "${LIBELF_BUILD_DIR}/lib/libelf.a")
  set(LIBELF_PKGCONFIG "${LIBELF_BUILD_DIR}/lib/pkgconfig")

  ExternalProject_Add(
    libelf
    URL "https://sourceware.org/elfutils/ftp/0.183/elfutils-0.183.tar.bz2"
    URL_HASH "SHA256=c3637c208d309d58714a51e61e63f1958808fead882e9b607506a29e5474f2c5"
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND PKG_CONFIG_PATH=${ZLIB_PKGCONFIG} ./configure --disable-debuginfod --prefix=${LIBELF_BUILD_DIR}
    BUILD_COMMAND make
  )

  if (USE_BUNDLED_ZLIB)
    add_dependencies(libelf zlib)
  endif ()

  message(STATUS "Using bundled libelf: include'${LIBELF_INCLUDE}', lib: ${LIBELF_LIB}")
endif ()