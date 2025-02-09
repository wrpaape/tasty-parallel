cmake_minimum_required(VERSION 3.28 FATAL_ERROR) # Support for C++ Modules

project(
    TastyParallel
    VERSION 0.0.0
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_EXTENSIONS OFF)
enable_testing()
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

add_subdirectory(thirdparty)

set(CMAKE_CXX_SCAN_FOR_MODULES ON)
if(WIN32 AND (CMAKE_CXX_COMPILER_ID STREQUAL "GNU"))
    # `stdc++exp` provides complete support for "experimental libstdc++
    # features" on `g++-14`.  This library is needed for `std::print()` and
    # `std::println()` support on Windows (see [release notes](
    # https://gcc.gnu.org/gcc-14/changes.html#libstdcxx)).
    link_libraries(stdc++exp)
endif()

add_subdirectory(groups)
add_subdirectory(applications)
