file(GLOB TEST_SOURCE_LIST CONFIGURE_DEPENDS "${bpf_harness_SOURCE_DIR}/tests/test_*.cpp")
add_executable(runner runner.cpp ${TEST_SOURCE_LIST})
target_compile_features(runner PRIVATE cxx_std_17)

target_link_libraries(runner PRIVATE bpf_harness ${LIBBPF_LIB} ${GTEST_LIB} ${GTEST_MAIN_LIB})
target_include_directories(runner PRIVATE ${LIBBPF_INCLUDE} ${GTEST_INCLUDE_DIR})

if (BPF_TEST_DEBUG)
  message(STATUS "BPF test debug mode enabled")
  target_compile_definitions(runner PRIVATE -DBPF_TEST_DEBUG)
endif ()