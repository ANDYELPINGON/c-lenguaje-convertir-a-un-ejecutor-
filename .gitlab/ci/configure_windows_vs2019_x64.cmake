if (NOT "$ENV{CMAKE_CI_NIGHTLY}" STREQUAL "")
  set(CMake_TEST_ANDROID_VS16 ON CACHE BOOL "")
  set(CMAKE_TESTS_CDASH_SERVER "https://open.cdash.org" CACHE STRING "")
endif()

include("${CMAKE_CURRENT_LIST_DIR}/configure_windows_vs_common.cmake")
