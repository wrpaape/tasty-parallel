cmake_minimum_required(VERSION 3.11 FATAL_ERROR) # Support 'FetchContent'

include(FetchContent)

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
    googletest
    benchmark
)
