# this is so that header files are considered as part of this target by editors and generators
file(GLOB HEADER_LIST CONFIGURE_DEPENDS "${bpf_harness_SOURCE_DIR}/include/bpf_harness/*.h")

set(LIBS_SOURCES
  "${LIBS_SOURCE_DIR}/driver/fillers_table.c"
  "${LIBS_SOURCE_DIR}/driver/syscall_table.c"
  "${LIBS_SOURCE_DIR}/driver/event_table.c"
  "${LIBS_SOURCE_DIR}/driver/flags_table.c"
  "${LIBS_SOURCE_DIR}/driver/dynamic_params_table.c")

add_library(bpf_harness filler_test.cpp probe_loader.c ${LIBS_SOURCES} ${HEADER_LIST})

target_include_directories(bpf_harness PUBLIC
  ${bpf_harness_SOURCE_DIR}/include
  "${LIBELF_INCLUDE}"
  "${ZLIB_INCLUDE}"
  "${LIBBPF_INCLUDE}"
  "${LIBS_SOURCE_DIR}")

target_link_libraries(bpf_harness PRIVATE ${LIBBPF_LIB} ${ZLIB_LIB} ${LIBELF_LIB})

add_dependencies(bpf_harness zlib libelf libbpf)
target_compile_features(bpf_harness PUBLIC cxx_std_11)

source_group(
  TREE "${PROJECT_SOURCE_DIR}/include"
  PREFIX "Header Files"
  FILES ${HEADER_LIST})
