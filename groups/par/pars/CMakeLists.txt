add_library(pars)
target_sources(
    pars
    PUBLIC
    FILE_SET tasty_pars TYPE CXX_MODULES FILES
        pars_dummy.cpp
        pars_dummy_subordinate.cpp
)

add_executable(pars_dummy_subordinate.t)
target_sources(
    pars_dummy_subordinate.t
    PRIVATE
    FILE_SET tasty_pars_dummy_subordinate_t TYPE CXX_MODULES FILES
        pars_dummy_subordinate.t.cpp
)
target_link_libraries(
    pars_dummy_subordinate.t
    PRIVATE
    GTest::gtest
    GTest::gtest_main
    pars
)
add_test(
    NAME    pars_dummy_subordinate.t
    COMMAND $<TARGET_FILE:pars_dummy_subordinate.t>
)
add_executable(pars_dummy.t)
target_sources(
    pars_dummy.t
    PRIVATE
    FILE_SET tasty_pars_dummy_t TYPE CXX_MODULES FILES
        pars_dummy.t.cpp
)
target_link_libraries(
    pars_dummy.t
    PRIVATE
    GTest::gtest
    GTest::gtest_main
    pars
)
add_test(
    NAME    pars_dummy.t
    COMMAND $<TARGET_FILE:pars_dummy.t>
)
