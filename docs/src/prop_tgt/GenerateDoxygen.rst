GENERATE_DOXYGEN
----------------

Boolean specifying whether or not to pass a target's source files to ``doxygen`` as input for documentation.

To exclude certain source files from documentation while keeping the target itself, see the source file property :prop_sf:`GENERATE_DOXYGEN`.

Upon introduction of a target, :prop_tgt:`GENERATE_DOXYGEN` gets initialized with the value in :variable:`DOXYGEN_GENERATE_DOXYGEN`, i.e.

.. code-block:: cmake

    # ...

    set(DOXYGEN_GENERATE_DOXYGEN ON)

    add_library(
        FooWithDocs # is included in the documentation
        # ...
    )

    set(DOXYGEN_GENERATE_DOXYGEN OFF)

    add_library(
        FooWithoutDocs # isn't included in the documentation
        # ...
    )

    # ...
