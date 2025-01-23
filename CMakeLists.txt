cmake_minimum_required(VERSION 3.28 FATAL_ERROR) # Support for C++ Modules

project(
    TastyParallel
    VERSION 0.0.0
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_SCAN_FOR_MODULES ON)
enable_testing()

add_subdirectory(groups)
add_subdirectory(applications)
