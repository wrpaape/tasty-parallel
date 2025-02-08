cmake_minimum_required(VERSION 3.28 FATAL_ERROR) # Support for C++ Modules

include_guard()
#[=======================================================================[.rst:
tasty_add_component_gtests
--------------------------

This Module defines ``tasty_setup_target_uor``:

::

    tasty_add_component_gtests(
        <target>
        <GTEST_SOURCES  <srcs>             >
        [TEST_REGEX     <regex>            ]
        [TEST_DEPS      <libs>             ]
        [EXTRA_ARGS     <test_args>        ]
        [LABELS         <<prop> <value>>...]
    )

which generates build targets [executables] for the specified
``GTEST_SOURCES``, add them as BDE tests and generate necessary build
dependencies and test labels.
#]=======================================================================]
find_package(BdeBuildSystem REQUIRED)
include(GoogleTest)

function(tasty_add_component_gtests target)
    cmake_parse_arguments(PARSE_ARGV 1
                          ""
                          ""
                          "TEST_REGEX"
                          "EXTRA_ARGS;LABELS;GTEST_SOURCES;TEST_DEPS")
    bbs_assert_no_unparsed_args("")

    if (NOT _GTEST_SOURCES)
        message(FATAL_ERROR "No sources for the test ${target}")
    endif()

    set(test_targets)

    foreach(gtest_src ${_GTEST_SOURCES})
        # Stripping all extensions from the gtest source ( including numbers
        # from the numbered tests )
        get_filename_component(gtest_name ${gtest_src} NAME_WE)
        if ((BDE_TEST_REGEX AND NOT ${gtest_name} MATCHES "${BDE_TEST_REGEX}")
            OR (_TEST_REGEX AND NOT ${gtest_name} MATCHES "${_TEST_REGEX}"))
            # Generate test target only for matching test regex, if any.
            continue()
        endif()

        # Stripping last 2 extentions from the test source (.g.cpp)
        get_filename_component(gtest_target_name ${gtest_src} NAME_WLE)
        get_filename_component(gtest_target_name ${gtest_target_name} NAME_WLE)
        add_executable(${gtest_target_name}.t)
        target_sources(${gtest_target_name}.t
                       PRIVATE
                       FILE_SET ${gtest_target_name}ModulePartition
                       TYPE     CXX_MODULES
                       FILES    ${gtest_src})

        # Explicitely adding flags here because we do not want those flags to be
        # PUBLIC for standalone libraries.
        bbs_add_target_bde_flags(${gtest_target_name}.t PRIVATE)
        bbs_add_target_thread_flags(${gtest_target_name}.t PRIVATE)

        target_link_libraries(${gtest_target_name}.t PUBLIC ${target} ${_TEST_DEPS} gtest gtest_main)

        if (BDE_BUILD_TARGET_FUZZ)
            target_link_libraries(${gtest_target_name}.t PRIVATE "-fsanitize=fuzzer")
        endif()

        gtest_discover_tests(${gtest_target_name}.t
                             DISCOVERY_TIMEOUT 10
                             EXTRA_ARGS        "${_EXTRA_ARGS}"
                            )


        set(test_src_labels ${gtest_name})
        if (NOT gtest_name STREQUAL test_target_name)
            list(APPEND test_src_labels ${gtest_target_name})
        endif()

        bbs_add_bde_style_gtest(${gtest_target_name}
                                LABELS            "${_LABELS}"
                                                  "${test_src_labels}")

        # Adding package test target
        if (NOT TARGET ${target}.t)
            add_custom_target(${target}.t)
        endif()

        if (NOT TARGET all.t)
            add_custom_target(all.t)
        endif()

        add_dependencies(${target}.t ${gtest_target_name}.t)
        add_dependencies(all.t ${gtest_target_name}.t)

        list(APPEND test_targets ${gtest_target_name}.t)

        # Adding top test target for numbered ( aka bslstl_vector for bslstl_vector.[0123].t )
        # True for numbered tests
        if (NOT gtest_name STREQUAL gtest_target_name)
            if (NOT TARGET ${gtest_name}.t)
                add_custom_target(${gtest_name}.t)
            endif()

            message(STATUS "Adding ${gtest_name}.t -> ${gtest_target_name}.t")
            add_dependencies(${gtest_name}.t ${test_target_name}.t)
        endif()
    endforeach()

    set(${target}_TEST_TARGETS "${test_targets}" PARENT_SCOPE)
endfunction()
