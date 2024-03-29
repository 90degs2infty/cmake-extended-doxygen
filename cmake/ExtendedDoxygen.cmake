#[========================================================================[.rst:
ExtendedDoxygen
---------------

Collection of helper properties and functions to ease the generation of
`Doxygen <https://doxygen.nl/>`_-based documentation from within ``cmake``.

``include``-ing :module:`ExtendedDoxygen` will check for

* `CMAKE_POLICY_DEFAULT_CMP0115 <https://cmake.org/cmake/help/latest/variable/CMAKE_POLICY_DEFAULT_CMPNNNN.html>`_
* `CMP0115 <https://cmake.org/cmake/help/latest/policy/CMP0115.html>`_
* `CMAKE_POLICY_DEFAULT_CMP0118 <https://cmake.org/cmake/help/latest/variable/CMAKE_POLICY_DEFAULT_CMPNNNN.html>`_
* `CMP0118 <https://cmake.org/cmake/help/latest/policy/CMP0118.html>`_

being set to ``NEW``.
See :ref:`prerequisites` for a discussion on why.

``include``-ing :module:`ExtendedDoxygen` transitively includes
:module:`DoxygenAddDocumentation`, i.e. there is no need to include the latter by
hand.
#]========================================================================]

# --------------------
# Check policy CMP0115, see https://cmake.org/cmake/help/latest/policy/CMP0115.html
# --------------------
# We want policy CMP0115 to be set to NEW, as this will make our lives easier when collecting sources

if(DEFINED CMAKE_POLICY_DEFAULT_CMP0115)
    if(NOT CMAKE_POLICY_DEFAULT_CMP0115 STREQUAL NEW)
        message(WARNING "CMAKE_POLICY_DEFAULT_CMP0115 not set to NEW. To silence this warning, explicitly set source file extensions and set CMAKE_POLICY_DEFAULT_CMP0115 to NEW. See https://cmake.org/cmake/help/latest/policy/CMP0115.html for details.")
    endif()
endif()

cmake_policy(GET CMP0115 CMP0115_VALUE)
if(NOT CMP0115_VALUE STREQUAL NEW)
        message(WARNING "CMP0115 not set to NEW. To silence this warning, explicitly set source file extensions and set CMP0115 to NEW. See https://cmake.org/cmake/help/latest/policy/CMP0115.html for details.")
endif()

# --------------------
# Check policy CMP0118, see https://cmake.org/cmake/help/latest/policy/CMP0118.html
# --------------------
# We want policy CMP0118 to be set to NEW, as this will make our lives easier when collecting sources

if(DEFINED CMAKE_POLICY_DEFAULT_CMP0118)
    if(NOT CMAKE_POLICY_DEFAULT_CMP0118 STREQUAL NEW)
        message(WARNING "CMAKE_POLICY_DEFAULT_CMP0118 not set to NEW. To silence this warning, set CMAKE_POLICY_DEFAULT_CMP0118 to NEW. See https://cmake.org/cmake/help/latest/policy/CMP0118.html for details.")
    endif()
endif()

cmake_policy(GET CMP0118 CMP0118_VALUE)
if(NOT CMP0118_VALUE STREQUAL NEW)
        message(WARNING "CMP0118 not set to NEW. To silence this warning, set CMP0118 to NEW. See https://cmake.org/cmake/help/latest/policy/CMP0118.html for details.")
endif()

# -------------------------------------------------
# Set the expected CMake version alongside policies
# -------------------------------------------------
# To query the surrounding policy setting using the GETs above,
# this call to cmake_minimum_required has to stay below the above GETs.
cmake_minimum_required(VERSION 3.25)

#[========================================================================[.rst:
Variables
^^^^^^^^^

``include``-ing :module:`ExtendedDoxygen` introduces the
:variable:`DOXYGEN_GENERATE_DOXYGEN` variable.
#]========================================================================]
set(DOXYGEN_GENERATE_DOXYGEN OFF)

#[========================================================================[.rst:
Properties
^^^^^^^^^^

``include``-ing :module:`ExtendedDoxygen` introduces two custom properties.
Targets introduced after the include will feature the
:prop_tgt:`GENERATE_DOXYGEN` target property.
Source files introduced after the include will feature the
:prop_sf:`GENERATE_DOXYGEN` sourcefile property.
#]========================================================================]
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

#[========================================================================[.rst:
Commands
^^^^^^^^
#]========================================================================]

#[========================================================================[.rst:
.. Hidden from output (internal helper)
    .. command:: collect_targets

        .. code-block:: cmake

            collect_targets(
                <returnVariable>
                <rootDirectory>
            )

        Recursively collect all targets defined in directory ``<rootDirectory>``
        and store the resulting list in variable ``<returnVariable>``.

        ``<returnVariable>``
            return variable that gets set in the caller's scope to hold the list of
            collected targets

        ``<rootDirectory>``
            top-most directory to traverse

            The specified directory must be known to ``cmake``, i.e. it has to have
            been introduced via ``add_subdirectory`` previously.
            Subdirectories that are known to ``cmake`` get traversed recursively.
#]========================================================================]
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

#[========================================================================[.rst:
.. Hidden from output (internal helper)
    .. command:: contains_genex

        .. code-block:: cmake

            contains_genex(
                <returnVariable>
                <filepath>
            )

        Check if the source file path ``<filepath>`` contains a generator expression
        and store the result in ``<returnVariable>``

        ``<returnVariable>``
            return variable that gets set in the caller's scope to hold a boolean
            indicating generator expressions

            ``ON``
                ``<filepath>`` contains a generator expression

            ``OFF``
                ``<filepath>`` does not contain a generator expression

        ``<filepath>``
            the source file path to check
#]========================================================================]
function(contains_genex var source)

    string(GENEX_STRIP "${source}" _no_genex)

    if(source STREQUAL _no_genex)
        set(${var} OFF PARENT_SCOPE)
    else()
        set(${var} ON PARENT_SCOPE)
    endif()
endfunction()

#[========================================================================[.rst:
.. Hidden from output (internal helper)
    .. command:: is_generated

        .. code-block:: cmake

            is_generated(
                <returnVariable>
                <filepath>
                <target>
            )

        Check if the given relative file path ``<filepath>`` refers to a generated
        file and store the result in ``<returnVariable>``.

        .. note::
            The source file's property ``GENERATED`` is evaluated in the specified
            target ``<target>``'s directory.
            I.e. the ``GENERATED`` source file property has to be visible from that
            directory.
            See
            `get_source_file_property <https://cmake.org/cmake/help/latest/command/get_source_file_property.html>`_
            for details.

        ``<returnVariable>``
            return variable that gets set in the caller's scope to hold the check's
            result

            ``ON``
                ``<filepath>`` is generated

            ``OFF``
                ``<filepath>`` is not generated

        ``<filepath>``
            the source file path to check

            ``<filepath>`` must be a relative path which is then evaluated relative
            to ``<target>``'s binary directory.

        ``<target>``
            target indicating the binary directory to search for ``<filepath>``

            The ``GENERATED`` source file property has to be visible from this
            target's directory, see the above.
#]========================================================================]
function(is_generated var source target)
    get_target_property(_target_binary_dir ${target} BINARY_DIR)

    # Note: the GENERATED property has some known unexpected behaviours and maybe even bugs.
    # See the following for a discussion:
    #
    # - https://discourse.cmake.org/t/unexpected-behavior-of-the-generated-source-file-property-and-cmp0118/3821/3
    # - https://discourse.cmake.org/t/behavior-of-where-cmp0118s-value-is-used-is-ambiguous/4045
    # - https://gitlab.kitware.com/cmake/cmake/-/issues/18399
    #
    # All in all, the current way to query the GENERATED property is to use `get_source_file_property` with
    # - the absolute path the generated file (the file does not have to exist on disc yet)
    # - the absolute path to the directory in which the file is introduced to CMake (i.e. the directory in
    #   which the introducing `CMakeLists.txt` lives)

    cmake_path(ABSOLUTE_PATH source BASE_DIRECTORY "${_target_binary_dir}" NORMALIZE OUTPUT_VARIABLE _generated_candidate)
    get_source_file_property(_generated "${_generated_candidate}" TARGET_DIRECTORY "${target}" GENERATED)
    set(${var} "${_generated}" PARENT_SCOPE)
endfunction()

#[========================================================================[.rst:
.. Hidden from output (internal helper)
    .. command:: collect_sources

        .. code-block:: cmake

            collect_sources(
                <returnVariable>
                <target>
            )

        Store the list of source files contributing to target ``<target>`` in
        ``<returnVariable>``.

        .. note::
            Collecting source files is not easy, so consider below implementation
            a draft approximation of correct behaviour.
            It works for basic use-cases, but it will certainly break for more
            complex ones.

        .. note::
            For a discussion on this, see
            `discourse <https://discourse.cmake.org/t/get-sources-of-target/4216/3>`_.
            Also see `SOURCES <https://cmake.org/cmake/help/latest/prop_tgt/SOURCES.html>`_
            for a specification of the types of paths that may arise as elements in
            ``SOURCES``.

        ``<returnVariable>``
            return variable that gets set in the caller's scope to hold the list of
            source files

        ``<target>``
            the target to evaluate
#]========================================================================]
function(collect_sources var target)
    list(APPEND CMAKE_MESSAGE_CONTEXT "collect_sources")

    get_target_property(_sources ${target} SOURCES)

    set(_sources_abs)

    foreach(_source IN LISTS _sources)
        absolutify_source(_source_absolute "${_source}" ${target})
        list(APPEND _sources_abs "${_source_absolute}")
    endforeach()

    set(${var} ${_sources_abs} PARENT_SCOPE)
endfunction()

function(absolutify_source var source target)
    list(APPEND CMAKE_MESSAGE_CONTEXT "absolutify_source")

    get_target_property(_target_source_dir ${target} SOURCE_DIR)
    get_target_property(_target_binary_dir ${target} BINARY_DIR)

    # There are several possibilities of what we get as input in `source`.
    # See https://cmake.org/cmake/help/latest/prop_tgt/SOURCES.html for details.
    # All in all, we employ the following steps:
    # 1. If `source` contains a genex, leave it as is. Genexes are expected to evaluate to absolute paths.
    # 2. If `source` is an absolute path, leave it as is.
    # 3. For everything else (i.e. relative paths):
    # 3.1 Check for the file being present in the binary dir. If it is present and it has the GENERATED
    #     property set, this file takes precedence. Return the absolute path to the
    #     found file (relative paths for generated files are always considered to be relative to the binary dir).
    #     If not, continue with 3.2.
    # 3.2 Check for the file being present in the source dir and the binary dir (in this
    #     order). Return the absolute path to the first location that points to an existing file.
    #     The GENERATED property does not matter.

    set(_source_abs)

    # check for genexes
    contains_genex(_has_genex "${source}")

    if(_has_genex)
        # there is a genex in source, according to the documentation we
        # may assume it evaluates to an absolute path
        # (see https://cmake.org/cmake/help/latest/prop_tgt/SOURCES.html)
        set(_source_abs "${source}")
    else()
        # no genex in source, path can be both relative and absolute
        cmake_path(IS_ABSOLUTE source _is_absolute)

        if(_is_absolute)
            # source is absolute path, nothing to do except normalization
            cmake_path(NORMAL_PATH source OUTPUT_VARIABLE _source_abs)
        else()

            message(
                WARNING
                "Relative path detected: ${source}. "
                "Consider using absolute paths to silence this warning. "
                "For basic use-cases it is sufficient to prepend \"${CMAKE_CURRENT_SOURCE_DIR}\". "
                "See https://github.com/90degs2infty/cmake-extended-doxygen#relative-paths for details."
            )

            # Check for a generated file
            is_generated(_generated ${source} ${target})
            if(_generated)
                set(_source_abs "${_generated_candidate}")
            else()
                # the path can be relative both to the target's source and binary directory,
                # hence we use `find_file` to search for the file
                cmake_path(GET source PARENT_PATH _source_relative)
                cmake_path(GET source FILENAME _source_filename)

                cmake_path(ABSOLUTE_PATH _source_relative BASE_DIRECTORY "${_target_source_dir}" NORMALIZE OUTPUT_VARIABLE _source_source_dir)
                cmake_path(ABSOLUTE_PATH _source_relative BASE_DIRECTORY "${_target_binary_dir}" NORMALIZE OUTPUT_VARIABLE _source_binary_dir)

                find_file(
                    _source_abs
                    "${_source_filename}"
                    PATHS "${_source_source_dir}" "${_source_binary_dir}"
                    NO_CACHE
                    REQUIRED
                    NO_DEFAULT_PATH
                )
            endif()
        endif()
    endif()

    set(${var} "${_source_abs}" PARENT_SCOPE)
endfunction()

#[========================================================================[.rst:
.. command:: collect_doxygen_input

    .. code-block:: cmake

        collect_doxygen_input(
            <returnVarSources>
            <returnVarIncludes>
            <rootDirectory>
        )

    Recursively collect all source files and include directories marked as input
    to doxygen.

    Collects all source files that contribute to some target defined at or below
    directoy ``<rootDirectory>`` with the property :prop_tgt:`GENERATE_DOXYGEN`
    enabled.
    For source file level exclusion of certain files, also see the source file
    property :prop_sf:`GENERATE_DOXYGEN`.

    Additionally, all include directories annotated to targets get collected.
    Here, the list of include directories is populated from the iterated
    targets' property `INTERFACE_INCLUDE_DIRECTORIES <https://cmake.org/cmake/help/latest/prop_tgt/INTERFACE_INCLUDE_DIRECTORIES.html>`_.

    .. note::
        There is no way of excluding certain include directories as there
        is for source files (yet).

    ``<returnVarSources>``
        return variable that gets set in the caller's scope to hold the list of
        source files acting as input to ``doxygen``

    ``<returnVarIncludes>``
        return variable that gets set in the caller's scope to hold the list of
        include directories

    ``<rootDirectory>``
        top-most directory to traverse

        The specified directory must be known to ``cmake``, i.e. it has to have
        been introduced via ``add_subdirectory`` previously.
        Subdirectories that are known to ``cmake`` get traversed recursively.
#]========================================================================]
function(collect_doxygen_input var_sources var_include_dirs dir)

    # Implementation note: the algorithm in here basically is the following:
    # 1: For all targets defined at or below the specified directory...
    # 2:   ...check, if the `GENERATE_DOCUMENTATION` property evaluates to
    #      `TRUE`
    # 3:     If yes: For all source files contained in the target's `SOURCE`
    #        property...
    # 4:       ...check, if there is an overriding `GENERATE_DOCUMENTATION`
    #          property evaluating to `FALSE`
    # 5:         If no: add the source file to the list of all source files
    # 6:       ...add all directories contained in the target's
    #          `INTERFACE_INCLUDE_DIRECTORIES` to the list of all include
    #          directories

    # Implementation note: for relative paths to work, I might have to switch the order of doing stuff below:
    # Loop over targets
    # Loop over targets' sources
    #   If generate_doxygen
    #       collect
    # Loop over collected sources
    #   absolutify paths

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

                # NOTE: to my understanding, it is not possible to set source file properties on files
                # which feature a genex in their path. At least, neither
                # https://cmake.org/cmake/help/latest/command/set_property.html nor
                # https://cmake.org/cmake/help/latest/command/set_source_files_properties.html#command:set_source_files_properties
                # mentions generator expressions.
                # Hence, we assume that for genex-sources, no source file property is set and the target
                # property GENERATE_DOXYGEN takes precedence.

                contains_genex(_has_genex "${_source}")

                if(NOT _has_genex)

                    # If not (GENERATE_DOXYGEN defined and false)
                    #
                    # Note that we have to query for GENERATE_DOXYGEN from the target's directory scope as otherwise the property
                    # will not be visible to us. See https://cmake.org/cmake/help/latest/command/set_source_files_properties.html for details.
                    get_property(_has_doxy_override SOURCE "${_source}" TARGET_DIRECTORY ${_target} PROPERTY GENERATE_DOXYGEN SET)
                    if(_has_doxy_override)
                        get_source_file_property(_gen_doxy_src "${_source}" TARGET_DIRECTORY ${_target} GENERATE_DOXYGEN)
                    endif()
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

# Pull in the custom drop-in replacement for doxygen_add_docs
include("${CMAKE_CURRENT_LIST_DIR}/DoxygenAddDocumentation.cmake")
