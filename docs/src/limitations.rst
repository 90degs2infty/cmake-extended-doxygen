.. _known-limitations:

Known limitations
=================

The implementation shipped in this repository is still in early development.
Hence, there are some limitations to keep in mind when using ``cmake-extended-doxygen`` (apart from the usual things that apply to early development projects).

Relative source file paths
^^^^^^^^^^^^^^^^^^^^^^^^^^

Depending on context, CMake interprets relative paths as relative to either the source or the binary directory.
Such paths have to be converted to absolute paths before passing them to Doxygen in order to uniquely identify files.

Part of the conversion depends on the `GENERATED <https://cmake.org/cmake/help/latest/prop_sf/GENERATED.html>`_ source file property.
Due to some unexpected behaviour in ``cmake``, querying this property can break the entire build under certain conditions.
See `this issue <https://gitlab.kitware.com/cmake/cmake/-/issues/24311>`_ for a detailed description of the unexpected behaviour.

Due to the unexpected behaviour, the integration contained in this repository currently only works with absolute file paths.
I.e. relative file paths are not allowed in source file paths contained in your ``CMakeLists.txt``.
As this is quite a bummer, please check the above issue and give feedback/upvote the issue.

To convert relative file paths contained in your ``CMakeLists.txt``, consider prepending ``${CMAKE_CURRENT_LIST_DIR}``.
I.e.

.. code-block:: cmake

    add_library(
        Foo
        relative/path/to/source.cpp # Instead of this, ...
        "${CMAKE_CURRENT_LIST_DIR}/relative/path/to/source.cpp" # ...use this.
    )

The same applies to paths relative to a target's binary directory.
