cmake_minimum_required(VERSION 3.28 FATAL_ERROR) # Support for C++ Modules

include_guard()
#[=======================================================================[.rst:
tasty_setup_target_uor
----------------------

This Module defines ``tasty_setup_target_uor``:

::

    tasty_setup_target_uor(
       <target>
       [SOURCE_DIR       <dir> ]
       [CUSTOM_PACKAGES  <pkgs>]
       [PRIVATE_PACKAGES <pkgs>]
       [SKIP_TESTS]
       [NO_GEN_BDE_METADATA]
       [NO_EMIT_PKG_CONFIG_FILE]
   )

which parses BDE metadata and configures a UOR target.
#]=======================================================================]
find_package(BdeBuildSystem REQUIRED)
include(tasty_configure_target_tests)

function(tasty_setup_target_uor target)
    cmake_parse_arguments(PARSE_ARGV 1
                          ""
                          "SKIP_TESTS;NO_GEN_BDE_METADATA;NO_EMIT_PKG_CONFIG_FILE"
                          "SOURCE_DIR"
                          "CUSTOM_PACKAGES;PRIVATE_PACKAGES")
    bbs_assert_no_unparsed_args("")

    # Get the name of the unit from the target
    get_target_property(uor_name ${target} NAME)

    message(VERBOSE "Processing target \"${target}\"")

    # Use the current source directory if none is specified
    if (NOT _SOURCE_DIR)
        set(_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
    endif()

    if (DEFINED BUILD_TESTING AND NOT BUILD_TESTING)
        set(_SKIP_TESTS TRUE)
    endif()

    # Check that BDE metadata exists and load it
    if (EXISTS ${_SOURCE_DIR}/group)
        bbs_read_metadata(GROUP ${uor_name}
                          SOURCE_DIR ${_SOURCE_DIR}
                          CUSTOM_PACKAGES "${_CUSTOM_PACKAGES}"
                          PRIVATE_PACKAGES "${_PRIVATE_PACKAGES}")
    else()
        if (EXISTS ${_SOURCE_DIR}/package)
            bbs_read_metadata(PACKAGE ${uor_name}
                              SOURCE_DIR ${_SOURCE_DIR})
        endif()
    endif()

    if (NOT ${uor_name}_METADATA_DIRS)
        message(FATAL_ERROR "Failed to find metadata for BDE unit: ${uor_name}")
    endif()

    # Check if the target is a library or executable
    get_target_property(_target_type ${target} TYPE)

    if (   _target_type STREQUAL "STATIC_LIBRARY"
        OR _target_type STREQUAL "SHARED_LIBRARY"
        OR _target_type STREQUAL "OBJECT_LIBRARY")
        # Ensure that the unit has at least one source file
        if (NOT ${uor_name}_SOURCE_FILES)
            message(FATAL_ERROR "No source files found for library: ${uor_name}")
        endif()

        # Check that there is no main file
        if (${uor_name}_MAIN_SOURCE)
            get_filename_component(_main_file ${${uor_name}_MAIN_SOURCE} NAME)
            message(FATAL_ERROR "Main file found in library ${uor_name}: ${_main_file}")
        endif()

        # Each package in the groups is an individual OBJECT or INTERFACE library
        if (${uor_name}_PACKAGES)
            foreach(pkg ${${uor_name}_PACKAGES})
                # Check if this is customized package
                if (${pkg} IN_LIST _CUSTOM_PACKAGES)
                    message(TRACE "Processing customized ${pkg}")
                    add_subdirectory(${_SOURCE_DIR}/${pkg})

                    # Custom package must "export" and interface library that can be ether
                    # OBJECT library target (if it contains compilable sources) or INTERFACE
                    # library target if it is header-only package. All we do here is to add
                    # group dependencies to the package interface and add it as a dependency
                    # to the group.
                    if (TARGET ${pkg}-iface)
                        get_target_property(_pkg_type ${pkg}-iface TYPE)
                        if (_pkg_type STREQUAL "OBJECT_LIBRARY")
                            target_link_libraries(${pkg}-iface PRIVATE ${${uor_name}_PCDEPS})
                            target_link_libraries(${target} PUBLIC ${pkg}-iface)
                        else()
                            target_link_libraries(${target} INTERFACE ${pkg}-iface)
                        endif()

                    else()
                        message(FATAL_ERROR "Custom package should produce an interface library")
                    endif()
                else()
                    message(TRACE "Processing ${pkg}")

                    # If the library contains only header files, we will create an INTERFACE
                    # library; otherwise, we will create an OBJECT library
                    if (${pkg}_SOURCE_FILES)
                        message(TRACE "Adding OBJECT library ${pkg}-iface")
                        add_library(${pkg}-iface OBJECT)
                        target_sources(${pkg}-iface
                                       PUBLIC
                                       FILE_SET ${pkg}ModulePartitions
                                       TYPE     CXX_MODULES
                                       FILES    ${${pkg}_SOURCE_FILES})

                        set_target_properties(${pkg}-iface PROPERTIES LINKER_LANGUAGE CXX)
                        bbs_add_target_include_dirs(${pkg}-iface PUBLIC ${${pkg}_INCLUDE_DIRS})

                        bbs_add_target_bde_flags(${pkg}-iface PRIVATE)
                        bbs_add_target_thread_flags(${pkg}-iface PRIVATE)

                        target_link_libraries(${pkg}-iface PRIVATE ${${uor_name}_PCDEPS})

                        # Adding library for the package as real static library
                        add_library(${pkg} STATIC)
                        target_link_libraries(${pkg} PUBLIC ${pkg}-iface)

                        # Important: link with DEPENDS and not PCDEPS for packages
                        # in a groups. For groups with underscores (z_bae) we do
                        # not want to use pc-fied name like z-baelu.
                        # For the group's dependencies (external) we use PCDEPS.
                        # This is different from a standalone packages that can
                        # have only external PC dependencies.
                        foreach(p ${${pkg}_DEPENDS})
                            target_link_libraries(${pkg}-iface PUBLIC ${p}-iface)
                            target_link_libraries(${pkg} INTERFACE ${p})
                        endforeach()

                        target_link_libraries(${target} PUBLIC ${pkg}-iface)
                    else()
                        message(TRACE "Adding INTERFACE library ${pkg}-iface")
                        add_library(${pkg}-iface INTERFACE ${${pkg}_INCLUDE_FILES})
                        bbs_add_target_include_dirs(${pkg}-iface INTERFACE ${${pkg}_INCLUDE_DIRS})

                        # Adding library for the package as an interface library
                        add_library(${pkg} INTERFACE)
                        target_link_libraries(${pkg} INTERFACE ${pkg}-iface)

                        foreach(p ${${pkg}_DEPENDS})
                            target_link_libraries(${pkg}-iface INTERFACE ${p}-iface)
                            target_link_libraries(${pkg} INTERFACE ${p})
                        endforeach()
                        target_link_libraries(${target} INTERFACE ${pkg}-iface)
                    endif()

                    # Generating cpp03 headers, implementation and test files if any
                    bbs_generate_cpp03_sources("${${pkg}_INCLUDE_FILES}")
                    bbs_generate_cpp03_sources("${${pkg}_SOURCE_FILES}")
                    bbs_generate_cpp03_sources("${${pkg}_TEST_SOURCES}")
                    bbs_generate_cpp03_sources("${${pkg}_SPLIT_TEST_SOURCES}" IMMEDIATE)

                    if (NOT _SKIP_TESTS)
                        tasty_configure_target_tests(${pkg}
                                                     TEST_SOURCES  ${${pkg}_TEST_SOURCES}
                                                     GTEST_SOURCES ${${pkg}_GTEST_SOURCES}
                                                     SPLIT_SOURCES ${${pkg}_SPLIT_TEST_SOURCES}
                                                     TEST_DEPS     ${${pkg}_DEPENDS}
                                                                   ${${pkg}_TEST_DEPENDS}
                                                                   ${${uor_name}_PCDEPS}
                                                                   ${${uor_name}_TEST_PCDEPS}
                                                     LABELS        "all" ${target} ${pkg})
                    endif()
                endif()
            endforeach()

            set_target_properties(${target} PROPERTIES LINKER_LANGUAGE CXX)
            set_target_properties(${target} PROPERTIES BB_UOR_IS_GROUP TRUE)

            target_link_libraries(${target} PUBLIC ${${uor_name}_PCDEPS})
            bbs_add_target_bde_flags(${target} PRIVATE)
            bbs_add_target_thread_flags(${target} PRIVATE)

            bbs_import_target_dependencies(${target} ${${uor_name}_PCDEPS})

            if (NOT _SKIP_TESTS)
                set(import_test_deps ON)
                set(import_gtest_deps ON)
                foreach(pkg ${${uor_name}_PACKAGES})
                    if (${pkg}_TEST_TARGETS)
                        if (NOT TARGET ${target}.t)
                            add_custom_target(${target}.t)
                        endif()
                        add_dependencies(${target}.t ${${pkg}_TEST_TARGETS})
                        if (import_test_deps)
                            # Import UOR test dependencies only once and only if we have at least
                            # one generated test target
                            bbs_import_target_dependencies(${target} ${${uor_name}_TEST_PCDEPS})
                            set(import_test_deps OFF)
                        endif()
                        if (${pkg}_GTEST_SOURCES)
                            if (import_gtest_deps)
                                # Import UOR test dependencies only once and only if we have gtests
                                bbs_import_target_dependencies(${target} gtest)
                                set(import_gtest_deps OFF)
                            endif()
                        endif()
                    endif()
                endforeach()
            endif()
        else()
            # Configure standalone library ( no packages ) and tests from BDE metadata
            message(VERBOSE "Adding library for ${target}")
            set_target_properties(${target} PROPERTIES LINKER_LANGUAGE CXX)
            target_sources(${target}
                           PUBLIC
                           FILE_SET ${uor_name}ModulePartitions
                           TYPE     CXX_MODULES
                           FILES    ${${uor_name}_SOURCE_FILES})
            bbs_add_target_include_dirs(${target} PUBLIC ${${uor_name}_INCLUDE_DIRS})

            target_link_libraries(${target} PUBLIC ${${uor_name}_PCDEPS})
            bbs_add_target_bde_flags(${target} PRIVATE)
            bbs_add_target_thread_flags(${target} PRIVATE)

            bbs_import_target_dependencies(${target} ${${uor_name}_PCDEPS})
            if (NOT _SKIP_TESTS)
                tasty_configure_target_tests(${target}
                                             TEST_SOURCES  ${${uor_name}_TEST_SOURCES}
                                             GTEST_SOURCES ${${uor_name}_GTEST_SOURCES}
                                             SPLIT_SOURCES ${${uor_name}_SPLIT_TEST_SOURCES}
                                             TEST_DEPS     ${${uor_name}_PCDEPS}
                                                           ${${uor_name}_TEST_PCDEPS}
                                             LABELS        "all" ${target})
                if (${target}_TEST_TARGETS)
                    bbs_import_target_dependencies(${target} ${${uor_name}_TEST_PCDEPS})
                endif()
                if (${target}_GTEST_SOURCES)
                    bbs_import_target_dependencies(${target} gtest)
                endif()
            endif()
        endif()

        # Generating .pc file. This will be a noop in non-Bloomberg build env (TODO:fix)
        if (NOT _NO_EMIT_PKG_CONFIG_FILE)
            bbs_emit_pkg_config(${target})
        endif()

        # Generate/install bdemetadata files. This will be a noop in non-Bloomberg build env.
        if (NOT _NO_GEN_BDE_METADATA)
            bbs_emit_bde_metadata(${target})
        endif()

        # Create an alias library with the pkgconfig name, if it is different from
        # the uor name and such a target doesn't exist yet.
        bbs_uor_to_pc_name(${uor_name} pc_name)
        if (NOT TARGET ${pc_name} AND NOT uor_name STREQUAL pc_name)
            add_library(${pc_name} ALIAS ${target})
        endif()

        # Create a custom target for checking UOR dependency cycles
        bbs_emit_check_cycles(${target})

    elseif (_target_type STREQUAL "EXECUTABLE")
        # Configure application package from BDE metadata. Fail if we loaded
        # metadata for a package group.
        if (${uor_name}_PACKAGES)
            message(FATAL_ERROR "Cannot create executable from package group: ${uor_name}")
        endif()

        message(TRACE "Processing application ${uor_name}")
        # We need a main file to build

        if (NOT ${uor_name}_MAIN_SOURCE)
            message(FATAL_ERROR "No main source found for application package: ${uor_name}")
        endif()

        set(lib_target "${uor_name}_lib")

        # Create a static or interface library that can be reused by both the
        # executable and its test drivers. An static library must have sources and
        # is used if this package contains component files, otherwise an interface
        # library is created.
        if (${uor_name}_SOURCE_FILES)
            add_library(${lib_target} STATIC)

            set_target_properties(${lib_target} PROPERTIES LINKER_LANGUAGE CXX)
            target_sources(${lib_target}
                           PUBLIC
                           FILE_SET ${lib_target}ModulePartitions
                           TYPE     CXX_MODULES
                           FILES    ${${uor_name}_SOURCE_FILES})
            bbs_add_target_include_dirs(${lib_target} PUBLIC "${${uor_name}_INCLUDE_DIRS}")
            target_link_libraries(${lib_target} PUBLIC "${${uor_name}_PCDEPS}")

            bbs_add_target_bde_flags(${lib_target} PUBLIC)
            bbs_add_target_thread_flags(${lib_target} PUBLIC)

            # Copy properties from executable target to corresponding properties
            # of created ${lib_target} target. This will correctly set compiler/linker
            # flags for sources based on the flags specified for executable target by user.
            foreach(prop LINK_LIBRARIES INCLUDE_DIRECTORIES COMPILE_FEATURES COMPILE_DEFINITIONS COMPILE_OPTIONS)
                get_target_property(value ${target} ${prop})
                if (value)
                    # All ${uor_name}_SOURCE_FILES should have correct flags.
                    set_property(TARGET ${lib_target} APPEND PROPERTY ${prop} ${value})
                    # All dependencies (executable and test drivers) should have correct flags.
                    set_property(TARGET ${lib_target} APPEND PROPERTY INTERFACE_${prop} ${value})
                endif()
            endforeach()

        else()
            add_library(${lib_target} INTERFACE)

            target_link_libraries(${lib_target} INTERFACE "${${uor_name}_PCDEPS}")
            bbs_add_target_include_dirs(${lib_target} INTERFACE "${${uor_name}_INCLUDE_DIRS}")

            bbs_add_target_bde_flags(${lib_target} INTERFACE)
            bbs_add_target_thread_flags(${lib_target} INTERFACE)

            # Copy properties from executable target to corresponding INTERFACE_* properties
            # of created ${lib_target} target. This will correctly set compiler/linker
            # flags for sources based on the flags specified for executable target by user.
            foreach(prop LINK_LIBRARIES INCLUDE_DIRECTORIES COMPILE_FEATURES COMPILE_DEFINITIONS COMPILE_OPTIONS)
                get_target_property(value ${target} ${prop})
                if (value)
                    # All dependencies (executable and test drivers) should have correct flags.
                    set_property(TARGET ${lib_target} APPEND PROPERTY INTERFACE_${prop} ${value})
                endif()
            endforeach()
        endif()

        # Create an alias for the application library to be used as an external
        # pkg-config compatible dependency
        bbs_uor_to_pc_name(${lib_target} pc_name)
        if (NOT TARGET ${pc_name} AND NOT ${lib_target} STREQUAL pc_name)
            add_library(${pc_name} ALIAS ${lib_target})
        endif()

        bbs_import_target_dependencies(${lib_target} "${${uor_name}_PCDEPS}")

        # Build the main source and link against the private library
        set_target_properties(${target} PROPERTIES LINKER_LANGUAGE CXX)
        target_sources(${target}
                       PRIVATE
                       FILE_SET ${uor_name}MainModulePartition
                       TYPE     CXX_MODULES
                       FILES    ${${uor_name}_MAIN_SOURCE})
        target_link_libraries(${target} PRIVATE ${lib_target})

        # Set up tests and link against the private library
        if (NOT _SKIP_TESTS)
            tasty_configure_target_tests(${lib_target}
                                         TEST_SOURCES  ${${uor_name}_TEST_SOURCES}
                                         GTEST_SOURCES ${${uor_name}_GTEST_SOURCES}
                                         SPLIT_SOURCES ${${uor_name}_SPLIT_TEST_SOURCES}
                                         TEST_DEPS     ${${uor_name}_PCDEPS}
                                                       ${${uor_name}_TEST_PCDEPS}
                                         LABELS        "all" ${target})
            if (TARGET ${lib_target}.t)
                if (NOT TARGET ${target}.t)
                    add_custom_target(${target}.t)
                endif()
                add_dependencies(${target}.t ${lib_target}.t)
            endif()

            if (${lib_target}_TEST_TARGETS)
                bbs_import_target_dependencies(${lib_target} ${${uor_name}_TEST_PCDEPS})
            endif()
        endif()
    else()
        # Not a library or an application
        message( FATAL_ERROR "Invalid target type for BDE target: ${_TARGET_TYPE}")
    endif()

    # TODO: support installation
    # if (_target_type STREQUAL "STATIC_LIBRARY" OR
    #     _target_type STREQUAL "EXECUTABLE")
    #     bbs_install_target(${target})
    # endif()
endfunction()
