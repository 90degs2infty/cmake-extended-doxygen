##########
# Preamble
##########
cmake_minimum_required(VERSION 3.25)

###############
# Project setup
###############
project(
    cmake-extended-doxygen
    VERSION 0.1.1
    DESCRIPTION "A target-based integration of Doxygen into CMake"
)

# Only add documenation option if explicitly asked to do so (via
# CED_PROVIDE_DOC_OPTION) or we're the toplevel project.
# Non-cache variable is used to make parent projects decide whether or not to
# expose this in the parent's cache or not.
if(CED_PROVIDE_DOC_OPTION OR _ced_is_toplevel)
    option(CED_BUILD_DOCUMENTATION "Build sphinx-based documentation" OFF)
endif()

# Detect if we're the toplevel project
if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    set(_ced_is_toplevel TRUE)
else()
    set(_ced_is_toplevel FALSE)
endif()

# Add cmake subdirectory to parents CMAKE_MODULE_PATH
if(NOT "${CMAKE_CURRENT_LIST_DIR}/cmake" IN_LIST CMAKE_MODULE_PATH)
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

    # the above append is visible in the current scope only, we have to
    # explicitly propagate to the caller's scope
    if(NOT _ced_is_toplevel)
        set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)
    endif()
endif()

####################
# Main build targets
####################
if(CED_BUILD_DOCUMENTATION)
    add_subdirectory(docs)
endif()
