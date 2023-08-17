# The function doxygen_add_documentation is based on the function doxygen_add_docs
# from CMake's sources (version 3.25.1).
# See https://cmake.org/cmake/help/latest/module/FindDoxygen.html for documentation.
# The function presented below does feature modifications compared to the original
# function.
#
# The original function doxygen_add_docs is distributed under the OSI-approved
# BSD 3-Clause License.
#
# Please find the license text here:
#
# CMake - Cross Platform Makefile Generator
# Copyright 2000-2023 Kitware, Inc. and Contributors
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
# * Neither the name of Kitware, Inc. nor the names of Contributors
#   may be used to endorse or promote products derived from this
#   software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# For details, also see
# https://gitlab.kitware.com/cmake/cmake/raw/master/Copyright.txt as
# well as https://cmake.org/licensing.

#[========================================================================[.rst:
DoxygenAddDocumentation
-----------------------

Commands
^^^^^^^^

#]========================================================================]

function(doxygen_add_documentation targetName)
    set(_options ALL USE_STAMP_FILE)
    set(_one_value_args WORKING_DIRECTORY COMMENT)
    set(_multi_value_args DEDICATED_SOURCES)
    cmake_parse_arguments(_args
                          "${_options}"
                          "${_one_value_args}"
                          "${_multi_value_args}"
                          ${ARGN})

    if(NOT _args_COMMENT)
        set(_args_COMMENT "Generate API documentation for ${targetName}")
    endif()

    if(NOT _args_WORKING_DIRECTORY)
        set(_args_WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    endif()

    if(DEFINED DOXYGEN_INPUT)
        message(WARNING
"DOXYGEN_INPUT is set but it will be ignored. Pass the files and directories \
directly to the doxygen_add_documentation() command instead.")
    endif()
    set(DOXYGEN_INPUT ${_args_UNPARSED_ARGUMENTS})

    if(_args_DEDICATED_SOURCES)
        list(APPEND DOXYGEN_INPUT ${_args_DEDICATED_SOURCES})
    endif()

    if(NOT TARGET Doxygen::doxygen)
        message(FATAL_ERROR "Doxygen was not found, needed by \
doxygen_add_documentation() for target ${targetName}")
    endif()

    # If not already defined, set some relevant defaults based on the
    # assumption that the documentation is for the whole project. Details
    # specified in the project() command will be used to populate a number of
    # these defaults.

    if(NOT DEFINED DOXYGEN_PROJECT_NAME)
        # The PROJECT_NAME tag is a single word (or a sequence of words
        # surrounded by double-quotes, unless you are using Doxywizard) that
        # should identify the project for which the documentation is generated.
        # This name is used in the title of most generated pages and in a few
        # other places. The default value is: My Project.
        set(DOXYGEN_PROJECT_NAME ${PROJECT_NAME})
    endif()

    if(NOT DEFINED DOXYGEN_PROJECT_NUMBER)
        # The PROJECT_NUMBER tag can be used to enter a project or revision
        # number. This could be handy for archiving the generated documentation
        # or if some version control system is used.
        set(DOXYGEN_PROJECT_NUMBER ${PROJECT_VERSION})
    endif()

    if(NOT DEFINED DOXYGEN_PROJECT_BRIEF)
        # Using the PROJECT_BRIEF tag one can provide an optional one line
        # description for a project that appears at the top of each page and
        # should give viewer a quick idea about the purpose of the project.
        # Keep the description short.
        set(DOXYGEN_PROJECT_BRIEF "${PROJECT_DESCRIPTION}")
    endif()

    if(NOT DEFINED DOXYGEN_RECURSIVE)
        # The RECURSIVE tag can be used to specify whether or not
        # subdirectories should be searched for input files as well. CMake
        # projects generally evolve to span multiple directories, so it makes
        # more sense for this to be on by default. Doxygen's default value
        # has this setting turned off, so we override it.
        set(DOXYGEN_RECURSIVE YES)
    endif()

    if(NOT DEFINED DOXYGEN_OUTPUT_DIRECTORY)
        # The OUTPUT_DIRECTORY tag is used to specify the (relative or
        # absolute) path into which the generated documentation will be
        # written. If a relative path is used, Doxygen will interpret it as
        # being relative to the location where doxygen was started, but we need
        # to run Doxygen in the source tree so that relative input paths work
        # intuitively. Therefore, we ensure that the output directory is always
        # an absolute path and if the project provided a relative path, we
        # treat it as relative to the current BINARY directory so that output
        # is not generated inside the source tree.
        set(DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
    elseif(NOT IS_ABSOLUTE "${DOXYGEN_OUTPUT_DIRECTORY}")
        get_filename_component(DOXYGEN_OUTPUT_DIRECTORY
                               "${DOXYGEN_OUTPUT_DIRECTORY}"
                               ABSOLUTE
                               BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
    endif()

    if(NOT DEFINED DOXYGEN_HAVE_DOT)
        # If you set the HAVE_DOT tag to YES then doxygen will assume the dot
        # tool is available from the path. This tool is part of Graphviz (see:
        # https://www.graphviz.org/), a graph visualization toolkit from AT&T
        # and Lucent Bell Labs. The other options in this section have no
        # effect if this option is set to NO.
        # Doxygen's default value is: NO.
        if(Doxygen_dot_FOUND)
          set(DOXYGEN_HAVE_DOT "YES")
        else()
          set(DOXYGEN_HAVE_DOT "NO")
        endif()
    endif()

    if(NOT DEFINED DOXYGEN_DOT_MULTI_TARGETS)
        # Set the DOT_MULTI_TARGETS tag to YES to allow dot to generate
        # multiple output files in one run (i.e. multiple -o and -T options on
        # the command line). This makes dot run faster, but since only newer
        # versions of dot (>1.8.10) support this, Doxygen disables this feature
        # by default.
        # This tag requires that the tag HAVE_DOT is set to YES.
        set(DOXYGEN_DOT_MULTI_TARGETS YES)
    endif()

    if(NOT DEFINED DOXYGEN_GENERATE_LATEX)
        # If the GENERATE_LATEX tag is set to YES, doxygen will generate LaTeX
        # output. We only want the HTML output enabled by default, so we turn
        # this off if the project hasn't specified it.
        set(DOXYGEN_GENERATE_LATEX NO)
    endif()

    if(NOT DEFINED DOXYGEN_WARN_FORMAT)
        if(CMAKE_VS_MSBUILD_COMMAND OR CMAKE_VS_DEVENV_COMMAND)
            # The WARN_FORMAT tag determines the format of the warning messages
            # that doxygen can produce. The string should contain the $file,
            # $line and $text tags, which will be replaced by the file and line
            # number from which the warning originated and the warning text.
            # Optionally, the format may contain $version, which will be
            # replaced by the version of the file (if it could be obtained via
            # FILE_VERSION_FILTER).
            # Doxygen's default value is: $file:$line: $text
            set(DOXYGEN_WARN_FORMAT "$file($line) : $text ")
        endif()
    endif()

    if(DEFINED DOXYGEN_WARN_LOGFILE AND NOT IS_ABSOLUTE "${DOXYGEN_WARN_LOGFILE}")
        # The WARN_LOGFILE tag can be used to specify a file to which warning and error
        # messages should be written. If left blank the output is written to standard
        # error (stderr).
        get_filename_component(DOXYGEN_WARN_LOGFILE
                               "${DOXYGEN_WARN_LOGFILE}"
                               ABSOLUTE
                               BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
    endif()

    # Any files from the INPUT that match any of the EXCLUDE_PATTERNS will be
    # excluded from the set of input files. We provide some additional patterns
    # to prevent commonly unwanted things from CMake builds being pulled in.
    #
    # Note that the wildcards are matched against the file with absolute path,
    # so to exclude all test directories for example use the pattern */test/*
    list(
        APPEND
        DOXYGEN_EXCLUDE_PATTERNS
        "*/.git/*"
        "*/.svn/*"
        "*/.hg/*"
        "*/CMakeFiles/*"
        "*/_CPack_Packages/*"
        "DartConfiguration.tcl"
        "CMakeLists.txt"
        "CMakeCache.txt"
    )

    # Now bring in Doxgen's defaults for those things the project has not
    # already set and we have not provided above
    include("${CMAKE_BINARY_DIR}/CMakeDoxygenDefaults.cmake" OPTIONAL)

    # Cleanup built HTMLs on "make clean"
    # TODO Any other dirs?
    if(DOXYGEN_GENERATE_HTML)
        if(IS_ABSOLUTE "${DOXYGEN_HTML_OUTPUT}")
            set(_args_clean_html_dir "${DOXYGEN_HTML_OUTPUT}")
        else()
            set(_args_clean_html_dir
                "${DOXYGEN_OUTPUT_DIRECTORY}/${DOXYGEN_HTML_OUTPUT}")
        endif()
        set_property(DIRECTORY APPEND PROPERTY
            ADDITIONAL_CLEAN_FILES "${_args_clean_html_dir}")
    endif()

    # Build up a list of files we can identify from the inputs so we can list
    # them as DEPENDS and SOURCES in the custom command/target (the latter
    # makes them display in IDEs). This must be done before we transform the
    # various DOXYGEN_... variables below because we need to process
    # DOXYGEN_INPUT as a list first.
    unset(_sources)
    foreach(_item IN LISTS DOXYGEN_INPUT)
        get_filename_component(_abs_item "${_item}" ABSOLUTE
                               BASE_DIR "${_args_WORKING_DIRECTORY}")
        get_source_file_property(_isGenerated "${_abs_item}" GENERATED)
        if(_isGenerated OR
           (EXISTS "${_abs_item}" AND
            NOT IS_DIRECTORY "${_abs_item}" AND
            NOT IS_SYMLINK "${_abs_item}"))
            list(APPEND _sources "${_abs_item}")
        elseif(_args_USE_STAMP_FILE)
            message(FATAL_ERROR "Source does not exist or is not a file:\n"
                "    ${_abs_item}\n"
                "Only existing files may be specified when the "
                "USE_STAMP_FILE option is given.")
        endif()
    endforeach()

    unset(_dedicated_sources)
    foreach(_item IN LISTS _args_DEDICATED_SOURCES)
        get_filename_component(_abs_item "${_item}" ABSOLUTE
                               BASE_DIR "${_args_WORKING_DIRECTORY}")
        get_source_file_property(_isGenerated "${_abs_item}" GENERATED)
        if(_isGenerated OR
           (EXISTS "${_abs_item}" AND
            NOT IS_DIRECTORY "${_abs_item}" AND
            NOT IS_SYMLINK "${_abs_item}"))
            list(APPEND _dedicated_sources "${_abs_item}")
        elseif(_args_USE_STAMP_FILE)
            message(FATAL_ERROR "Source does not exist or is not a file:\n"
                "    ${_abs_item}\n"
                "Only existing files may be specified when the "
                "USE_STAMP_FILE option is given.")
        endif()
    endforeach()

    # Transform known list type options into space separated strings.
    set(_doxygen_list_options
        ABBREVIATE_BRIEF
        ALIASES
        CITE_BIB_FILES
        DIAFILE_DIRS
        DOTFILE_DIRS
        DOT_FONTPATH
        ENABLED_SECTIONS
        EXAMPLE_PATH
        EXAMPLE_PATTERNS
        EXCLUDE
        EXCLUDE_PATTERNS
        EXCLUDE_SYMBOLS
        EXPAND_AS_DEFINED
        EXTENSION_MAPPING
        EXTRA_PACKAGES
        EXTRA_SEARCH_MAPPINGS
        FILE_PATTERNS
        FILTER_PATTERNS
        FILTER_SOURCE_PATTERNS
        HTML_EXTRA_FILES
        HTML_EXTRA_STYLESHEET
        IGNORE_PREFIX
        IMAGE_PATH
        INCLUDE_FILE_PATTERNS
        INCLUDE_PATH
        INPUT
        LATEX_EXTRA_FILES
        LATEX_EXTRA_STYLESHEET
        MATHJAX_EXTENSIONS
        MSCFILE_DIRS
        PLANTUML_INCLUDE_PATH
        PREDEFINED
        QHP_CUST_FILTER_ATTRS
        QHP_SECT_FILTER_ATTRS
        STRIP_FROM_INC_PATH
        STRIP_FROM_PATH
        TAGFILES
        TCL_SUBST
    )
    foreach(_item IN LISTS _doxygen_list_options)
        doxygen_list_to_quoted_strings(DOXYGEN_${_item})
    endforeach()

    # Transform known single value variables which may contain spaces, such as
    # paths or description strings.
    set(_doxygen_quoted_options
        CHM_FILE
        DIA_PATH
        DOCBOOK_OUTPUT
        DOCSET_FEEDNAME
        DOCSET_PUBLISHER_NAME
        DOT_FONTNAME
        DOT_PATH
        EXTERNAL_SEARCH_ID
        FILE_VERSION_FILTER
        GENERATE_TAGFILE
        HHC_LOCATION
        HTML_FOOTER
        HTML_HEADER
        HTML_OUTPUT
        HTML_STYLESHEET
        INPUT_FILTER
        LATEX_FOOTER
        LATEX_HEADER
        LATEX_OUTPUT
        LAYOUT_FILE
        MAN_OUTPUT
        MAN_SUBDIR
        MATHJAX_CODEFILE
        MSCGEN_PATH
        OUTPUT_DIRECTORY
        PERL_PATH
        PLANTUML_JAR_PATH
        PROJECT_BRIEF
        PROJECT_LOGO
        PROJECT_NAME
        QCH_FILE
        QHG_LOCATION
        QHP_CUST_FILTER_NAME
        QHP_VIRTUAL_FOLDER
        RTF_EXTENSIONS_FILE
        RTF_OUTPUT
        RTF_STYLESHEET_FILE
        SEARCHDATA_FILE
        USE_MDFILE_AS_MAINPAGE
        WARN_FORMAT
        WARN_LOGFILE
        XML_OUTPUT
    )

    # Store the unmodified value of DOXYGEN_OUTPUT_DIRECTORY prior to invoking
    # doxygen_quote_value() below. This will mutate the string specifically for
    # consumption by Doxygen's config file, which we do not want when we use it
    # later in the custom target's commands.
    set( _original_doxygen_output_dir ${DOXYGEN_OUTPUT_DIRECTORY} )

    foreach(_item IN LISTS _doxygen_quoted_options)
        doxygen_quote_value(DOXYGEN_${_item})
    endforeach()

    # Prepare doxygen configuration file
    set(_doxyfile_template "${CMAKE_BINARY_DIR}/CMakeDoxyfile.in")
    set(_genex_template "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile.genex_in.${targetName}")
    set(_target_doxyfile "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile.${targetName}.$<CONFIG>")
    configure_file("${_doxyfile_template}" "${_genex_template}" @ONLY)
    file(GENERATE
        OUTPUT "${_target_doxyfile}"
        INPUT "${_genex_template}"
    )

    unset(_all)
    if(${_args_ALL})
        set(_all ALL)
    endif()

    # Only create the stamp file if asked to. If we don't create it,
    # the target will always be considered out-of-date.
    if(_args_USE_STAMP_FILE)
        set(__stamp_file "${CMAKE_CURRENT_BINARY_DIR}/${targetName}.stamp")
        add_custom_command(
            VERBATIM
            OUTPUT ${__stamp_file}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${_original_doxygen_output_dir}
            COMMAND "${DOXYGEN_EXECUTABLE}" "${_target_doxyfile}"
            COMMAND ${CMAKE_COMMAND} -E touch ${__stamp_file}
            WORKING_DIRECTORY "${_args_WORKING_DIRECTORY}"
            DEPENDS "${_target_doxyfile}" ${_sources}
            COMMENT "${_args_COMMENT}"
        )
        add_custom_target(${targetName} ${_all}
            DEPENDS ${__stamp_file}
            SOURCES ${_dedicated_sources}
        )
        unset(__stamp_file)
    else()
        add_custom_target( ${targetName} ${_all} VERBATIM
            COMMAND ${CMAKE_COMMAND} -E make_directory ${_original_doxygen_output_dir}
            COMMAND "${DOXYGEN_EXECUTABLE}" "${_target_doxyfile}"
            WORKING_DIRECTORY "${_args_WORKING_DIRECTORY}"
            DEPENDS "${_target_doxyfile}" ${_sources}
            COMMENT "${_args_COMMENT}"
            SOURCES ${_dedicated_sources}
        )
    endif()

endfunction()