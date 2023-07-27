include(RunCMake)

function(create_library type platform system_name archs)
  set(RunCMake_TEST_BINARY_DIR ${RunCMake_BINARY_DIR}/create-${type}-${platform}-build)
  run_cmake_with_options(create-${type}-${platform} -DCMAKE_SYSTEM_NAME=${system_name} -DCMAKE_OSX_ARCHITECTURES=${archs} -DCMAKE_INSTALL_PREFIX=${RunCMake_TEST_BINARY_DIR}/install)

  set(RunCMake_TEST_NO_CLEAN 1)
  run_cmake_command(create-${type}-${platform}-build ${CMAKE_COMMAND} --build . --config Release)
  run_cmake_command(create-${type}-${platform}-install ${CMAKE_COMMAND} --install . --config Release)
endfunction()

function(create_libraries type)
  create_library(${type} macos Darwin "${macos_archs_2}")
  create_library(${type} ios iOS "arm64")
  create_library(${type} tvos tvOS "arm64")
  create_library(${type} watchos watchOS "armv7k\\\\;arm64_32")
  if(CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 15)
    create_library(${type} visionos visionOS "arm64")
  endif()
endfunction()

function(create_xcframework name type platforms)
  set(RunCMake_TEST_BINARY_DIR ${RunCMake_BINARY_DIR}/create-xcframework-${name}-build)
  set(args)
  foreach(platform IN LISTS platforms)
    if(type STREQUAL "framework")
      list(APPEND args -framework ${RunCMake_BINARY_DIR}/create-${type}-${platform}-build/install/lib/mylib.framework)
    else()
      list(APPEND args -library ${RunCMake_BINARY_DIR}/create-${type}-${platform}-build/install/lib/libmylib.a -headers ${RunCMake_SOURCE_DIR}/mylib/include)
    endif()
  endforeach()
  run_cmake_command(create-xcframework-${name} xcodebuild -create-xcframework ${args} -output ${RunCMake_TEST_BINARY_DIR}/mylib.xcframework)
endfunction()

function(create_executable name xcfname system_name archs)
  set(RunCMake_TEST_BINARY_DIR ${RunCMake_BINARY_DIR}/create-executable-${name}-build)
  run_cmake_with_options(create-executable-${name} -DCMAKE_SYSTEM_NAME=${system_name} -DCMAKE_OSX_ARCHITECTURES=${archs} -DMYLIB_LIBRARY=${RunCMake_BINARY_DIR}/create-xcframework-${xcfname}-build/mylib.xcframework)

  set(RunCMake_TEST_NO_CLEAN 1)
  run_cmake_command(create-executable-${name}-build ${CMAKE_COMMAND} --build . --config Release)
endfunction()

function(create_executables name type)
  create_executable(${name}-macos ${type} Darwin "${macos_archs_2}")
  create_executable(${name}-ios ${type} iOS "arm64")
  create_executable(${name}-tvos ${type} tvOS "arm64")
  create_executable(${name}-watchos ${type} watchOS "armv7k\\\\;arm64_32")
  if(CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 15)
    create_executable(${name}-visionos ${type} visionOS "arm64")
  endif()
endfunction()

set(xcframework_platforms macos ios tvos watchos)
if(CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 15)
  list(APPEND xcframework_platforms visionos)
endif()
if(CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 12)
  set(macos_archs_1 "x86_64\\;arm64")
  set(macos_archs_2 "x86_64\\\\;arm64")
else()
  set(macos_archs_1 "x86_64")
  set(macos_archs_2 "x86_64")
endif()

create_libraries(library)
create_libraries(framework)
create_xcframework(library library "${xcframework_platforms}")
create_xcframework(framework framework "${xcframework_platforms}")
create_xcframework(incomplete framework "tvos;watchos")
create_executables(library library)
create_executables(framework framework)
run_cmake_with_options(create-executable-incomplete -DCMAKE_SYSTEM_NAME=Darwin "-DCMAKE_OSX_ARCHITECTURES=${macos_archs_1}" -DMYLIB_LIBRARY=${RunCMake_BINARY_DIR}/create-xcframework-incomplete-build/mylib.xcframework)
create_executables(target-library library)
create_executables(target-framework framework)
run_cmake_with_options(create-executable-target-incomplete -DCMAKE_SYSTEM_NAME=Darwin "-DCMAKE_OSX_ARCHITECTURES=${macos_archs_1}" -DMYLIB_LIBRARY=${RunCMake_BINARY_DIR}/create-xcframework-incomplete-build/mylib.xcframework)
if(RunCMake_GENERATOR STREQUAL "Xcode" AND CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 12)
  create_executables(library-link-phase library)
  create_executables(framework-link-phase framework)
  run_cmake_with_options(create-executable-incomplete-link-phase -DCMAKE_SYSTEM_NAME=Darwin "-DCMAKE_OSX_ARCHITECTURES=${macos_archs_1}" -DMYLIB_LIBRARY=${RunCMake_BINARY_DIR}/create-xcframework-incomplete-build/mylib.xcframework)
  create_executables(target-library-link-phase library)
  create_executables(target-framework-link-phase framework)
  run_cmake_with_options(create-executable-target-incomplete-link-phase -DCMAKE_SYSTEM_NAME=Darwin "-DCMAKE_OSX_ARCHITECTURES=${macos_archs_1}" -DMYLIB_LIBRARY=${RunCMake_BINARY_DIR}/create-xcframework-incomplete-build/mylib.xcframework)
endif()
