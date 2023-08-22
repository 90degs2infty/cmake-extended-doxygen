GENERATE_DOXYGEN
----------------

Boolean specifying whether or not to pass a specific source file to ``doxygen`` as input for documentation.
See the target property :prop_tgt:`GENERATE_DOXYGEN` for a target-wide equivalent.

When set on a source file and set to a non-truthy value (``OFF``, ``FALSE``, ...), the source file will not be passed on to ``doxygen`` even if the parent target has its target property :prop_tgt:`GENERATE_DOXYGEN` enabled.

.. note::
    For the source file property :prop_sf:`GENERATE_DOXYGEN` to have any effect, the parent target has to have :prop_tgt:`GENERATE_DOXYGEN` enabled.
    I.e. with the parent target property being disabled, a given source file will not get documented irrespective of the source file property's value.

.. note::
    The source file property :prop_sf:`GENERATE_DOXYGEN` has to be visible in the parent target's directory scope.
    By default, this is the case if the property is being set in the same ``CMakeLists.txt`` that introduces the target.

    For more complex source layouts (as recommended by the ``cmake`` docs), consider the following example.
    Given some library ``libfoo`` in directory ``foo`` with the source files living in subdirectory ``src``.
    Then set :prop_sf:`GENERATE_DOXYGEN` as follows:

    .. code-block:: cmake

        # foo/CMakeLists.txt

        add_library(
            foo
        )

        set_target_properties(
            foo
            PROPERTIES
            GENERATE_DOXYGEN ON
        )

        add_subdirectory(src)

        # foo/src/CMakeLists.txt

        target_sources(
            foo
            PRIVATE
            "${CMAKE_CURRENT_LIST_DIR}/bar.cpp"
            # ...
        )

        set_source_files_properties(
            "${CMAKE_CURRENT_LIST_DIR}/bar.cpp"
            TARGET_DIRECTORY foo # extend visibility of below property
            PROPERTIES
            GENERATE_DOXYGEN OFF
        )

    See `set_source_file_properties <https://cmake.org/cmake/help/latest/command/set_source_files_properties.html>`_ for details on visibility.
