include_guard()
#[=======================================================================[.rst:
tasty_configure_target_tests
----------------------------

This Module defines ``tasty_configure_target_tests``:

::

    tasty_configure_target_tests(
        <target>
        [TEST_SOURCES  <source.t.cpp>...  ]
        [SPLIT_SOURCES <source.xt.cpp>... ]
        [GTEST_SOURCES <source.g.cpp>...  ]
        [SOURCES       <source.cpp>...    ]
        [TEST_DEPS     <libs>             ]
        [LABELS        <<prop> <value>>...]
    )

which configures tests from the specified sources and adds the target as their
main build dependency.
#]=======================================================================]
find_package(BdeBuildSystem REQUIRED)
include(tasty_add_component_gtests)

function(tasty_configure_target_tests target)
    cmake_parse_arguments(""
                          ""
                          ""
                          "TEST_SOURCES;SOURCES;GTEST_SOURCES;SPLIT_SOURCES;TEST_DEPS;LABELS"
                          ${ARGN})
    bbs_assert_no_unparsed_args("")

    if (_TEST_SOURCES)
        bbs_add_component_tests(${target}
                                TEST_SOURCES  ${_TEST_SOURCES}
                                TEST_DEPS     ${_TEST_DEPS}
                                LABELS        ${_LABELS})
        set(${target}_TEST_TARGETS "${${target}_TEST_TARGETS}" PARENT_SCOPE)
    endif()
    if (_SOURCES)
        bbs_add_component_tests(${target}
                                TEST_SOURCES  ${_SOURCES}
                                TEST_DEPS     ${_TEST_DEPS}
                                LABELS        ${_LABELS})
        set(${target}_TEST_TARGETS "${${target}_TEST_TARGETS}" PARENT_SCOPE)
    endif()
    if (_GTEST_SOURCES)
        tasty_add_component_gtests(${target}
                                   GTEST_SOURCES ${_GTEST_SOURCES}
                                   TEST_DEPS     ${_TEST_DEPS}
                                   LABELS        ${_LABELS})
        set(${target}_TEST_TARGETS "${${target}_TEST_TARGETS}" PARENT_SCOPE)
    endif()
    if (_SPLIT_SOURCES)
        bbs_add_component_tests(${target}
                                SPLIT_SOURCES ${_SPLIT_SOURCES}
                                TEST_DEPS     ${_TEST_DEPS}
                                LABELS        ${_LABELS})
        set(${target}_TEST_TARGETS "${${target}_TEST_TARGETS}" PARENT_SCOPE)
    endif()
endfunction()
