#
# Copyright (C) 2021 The Falco Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
#

cmake_minimum_required(VERSION 3.5.1)

project(
  bpf_harness
  VERSION 0.1
  DESCRIPTION "Falco BPF probe harness suite"
  LANGUAGES CXX C)

option(BPF_TEST_DEBUG "Enable debug mode for the BPF driver tests (prints debug logs and the bpf_printk buffer, you will need a probe compiled with -DDEBUG)" OFF)

set(LIBS_SOURCE_DIR ../../libs)
if (FALCOSECURITY_LIBS_SOURCE_DIR)
  set(LIBS_SOURCE_DIR ${FALCOSECURITY_LIBS_SOURCE_DIR})
endif ()


# Custom CMake modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

# Out of source builds
file(TO_CMAKE_PATH "${PROJECT_BINARY_DIR}/CMakeLists.txt" LOC_PATH)
if (EXISTS "${LOC_PATH}")
  message(FATAL_ERROR "You cannot build in a source directory (or any directory with a CMakeLists.txt file). Please make a build subdirectory. Feel free to remove CMakeCache.txt and CMakeFiles.")
endif ()

include(ExternalProject)
include(zlib)
include(libelf)
include(libbpf)
include(googletest)

add_subdirectory(src)
add_subdirectory(tests)
