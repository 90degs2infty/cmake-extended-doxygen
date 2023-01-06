set(DOXYGEN_GENERATE_DOXYGEN OFF)

define_property(
    TARGET
    PROPERTY GENERATE_DOXYGEN
    INITIALIZE_FROM_VARIABLE DOXYGEN_GENERATE_DOXYGEN
)

define_property(
    SOURCE
    PROPERTY GENERATE_DOXYGEN
    # Note that we do not set this SOURCE property to inherit from the
    # corresponding target property, as source properties chain to DIRECTORY
    # scope instead of TARGET scope.
    # (see the INHERITED option at https://cmake.org/cmake/help/latest/command/define_property.html)
)

# ---------------
# Helper to collect targets
# ---------------

# collect_targets(VAR DIR)
#
# Recursively collects all targets defined in directory DIR
# and stores the resulting list in variable VAR.
#
# Arguments:
# - VAR: the output variable holding the list of targets
# - DIR: the top-most directory to traverse, must be known to CMake
#        subdirectories that are known to CMake get traversed recursively
function(collect_targets var dir)

    # Do the heavy lifting
    set(_targets)
    collect_targets_recursive(_targets "${dir}")

    # Propagate result to caller
    set(${var} ${_targets} PARENT_SCOPE)
endfunction()

macro(collect_targets_recursive targets dir)

    # Descend into subdirectories
    get_property(_subdirectories DIRECTORY "${dir}" PROPERTY SUBDIRECTORIES)
    foreach(_subdir IN LISTS _subdirectories)
        collect_targets_recursive(${targets} "${_subdir}")
    endforeach()

    # Collect targets at current directory level
    get_property(_current_targets DIRECTORY "${dir}" PROPERTY BUILDSYSTEM_TARGETS)
    list(APPEND ${targets} ${_current_targets})
endmacro()

# -----------------------------
# Helper to collect a target's sources
# -----------------------------

# collect_sources(VAR TARGET)
#
# Collects source files contributing to target TARGET in
# variable VAR.
#
# Arguments:
# - VAR:    the output variable holding the list of sources
# - TARGET: the target to process
#
# For a discussion on this, see https://discourse.cmake.org/t/get-sources-of-target/4216/3
# Also see https://cmake.org/cmake/help/latest/prop_tgt/SOURCES.html for a specification of
# the types of paths that may arise as elements in SOURCES.
#
# Note that collecting source files is not easy, so consider below implementation
# a draft approximation of correct behaviour. It works for basic use-cases, but it will
# certainly break for more complex ones.
function(collect_sources var target)

    get_target_property(_sources ${target} SOURCES)
    get_target_property(_target_source_dir ${target} SOURCE_DIR)
    get_target_property(_target_binary_dir ${target} BINARY_DIR)

    set(_abs_sources)

    foreach(_source IN LISTS _sources)
        if(NOT IS_ABSOLUTE "${_source}")
            get_source_file_property(_generated "${_source}" GENERATED)
            if(_generated)
                string(PREPEND _source "${_target_binary_dir}/")
            else()
                string(PREPEND _source "${_target_source_dir}/")
                # NOTE that we do not catch all possible cases from https://cmake.org/cmake/help/latest/prop_tgt/SOURCES.html
                # in here. E.g. the relative path could be relative to the binary directory even though GENERATED is not set.
            endif()
        endif()
        list(APPEND _abs_sources "${_source}")
    endforeach()

    set(${var} ${_abs_sources} PARENT_SCOPE)
endfunction()

# ----------------------------
# Helper to collect and include directories
# ----------------------------
# collect_doxygen_input(VAR_SOURCES VAR_INCLUDE_DIRS DIR)
#
# Recursively collect all doxygen-relevant source files and
# include directories of targets defined at or below the
# specified directory DIR.
#
# Arguments:
# - VAR_SOURCES:      the output variable holding the list of sources that should be documented
# - VAR_INCLUDE_DIRS: the output variable holding the list of include directories that should
#                     be stripped by doxygen
# - DIR:              the top-most directory to traverse, must be known to CMake
#                     subdirectories that are known to CMake get traversed recursively
function(collect_doxygen_input var_sources var_include_dirs dir)
    list(APPEND CMAKE_MESSAGE_CONTEXT "collect_doxygen_input")

    set(_doxy_sources)
    set(_doxy_includes)

    # Collect targets
    collect_targets(_targets "${dir}")
    message(DEBUG "Processing targets ${_targets}")

    # Loop over targets
    foreach(_target IN LISTS _targets)
        # If the target is marked to be included in the documentation
        get_target_property(_gen_doxy ${_target} GENERATE_DOXYGEN)
        message(DEBUG "Target ${_target}")
        message(DEBUG "  GENERATE_DOXYGEN ${_gen_doxy}")
        if(_gen_doxy)
            # Loop over target's sources
            collect_sources(_sources ${_target})
            foreach(_source IN LISTS _sources)
                set(_gen_doxy_src ON)

                # If not (GENERATE_DOXYGEN defined and false)
                get_property(_has_doxy_override SOURCE "${_source}" PROPERTY GENERATE_DOXYGEN SET)
                if(_has_doxy_override)
                    get_source_file_property(_gen_doxy_src "${_source}" GENERATE_DOXYGEN)
                endif()

                # Collect source
                if(_gen_doxy_src)
                    list(APPEND _doxy_sources "${_source}")
                endif()
            endforeach()

            # Loop over targets interface include directories
            # NOTE: no distinction between install interface vs. build interface so far
            get_property(_has_inc_interface TARGET ${_target} PROPERTY INTERFACE_INCLUDE_DIRECTORIES SET)
            if(_has_inc_interface)
                get_target_property(_includes ${_target} INTERFACE_INCLUDE_DIRECTORIES)
                list(APPEND _doxy_includes "${_includes}")
            endif()
        endif()
    endforeach()

    set(${var_sources} "${_doxy_sources}" PARENT_SCOPE)
    set(${var_include_dirs} "${_doxy_includes}" PARENT_SCOPE)
endfunction()
