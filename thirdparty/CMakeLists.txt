cmake_minimum_required(VERSION 3.11 FATAL_ERROR) # Support 'FetchContent'

include(FetchContent)

FetchContent_Declare(
    bde-tools
    GIT_REPOSITORY  https://github.com/bloomberg/bde-tools.git
    GIT_TAG         main
)
FetchContent_Declare(
    googletest
    GIT_REPOSITORY  https://github.com/google/googletest.git
    GIT_TAG         main
)
FetchContent_Declare(
    benchmark
    GIT_REPOSITORY  https://github.com/google/benchmark.git
    GIT_TAG         main
)
FetchContent_MakeAvailable(
    bde-tools
    googletest
    benchmark
)

find_package(BdeBuildSystem REQUIRED PATHS ${bde-tools_SOURCE_DIR})
