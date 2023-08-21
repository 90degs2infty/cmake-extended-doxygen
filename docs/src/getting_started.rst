.. _getting-started:

Getting started
===============

.. _prerequisites:

Prerequisites
-------------

* | ``cmake >= 3.25``
  | Policies `CMP0115 <https://cmake.org/cmake/help/latest/policy/CMP0015.html>`_ and `CMP0118 <https://cmake.org/cmake/help/latest/policy/CMP0118.html>`_ have to be set to ``NEW``, i.e. source file extensions have to be specified explicitly and the ``GENERATED`` source file property must be visible from all directories.

  Technically it would be possible to implement this integration without the need for the aforementioned policy setting.
  It eases internal processing, though.

* | `doxygen <https://doxygen.nl/>`_
  | Version ``1.9.4`` has been tested, older versions may work as well.

To build ``cmake-extended-doxygen``'s ``sphinx``-based documentation locally, you also need

* | `sphinx-build <https://www.sphinx-doc.org/en/master/>`_
  | Version ``7.1.2`` has been tested - other versions may work as well.
* | `sphinxcontrib-moderncmakedomain <https://github.com/scikit-build/moderncmakedomain>`_
  | Again, version ``3.27.0`` has been tested - other versions may work as well.

Usage
-----

Generating documentation consists of three high-level steps: pulling in ``cmake-extended-doxygen``, collecting input for ``doxygen`` and driving the eventual generation afterwards.

Getting ``cmake-extended-doxygen``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Early in your ``CMakeLists.txt``, pull in ``cmake-extended-doxygen`` (e.g. via ``FetchContent``).
This has to be done before you start introducing your targets, as otherwise your targets will lack the :prop_tgt:`GENERATE_DOXYGEN` property.

.. note::
  ``cmake-extended-doxygen`` does not search for ``doxygen``.
  Make sure to issue a suitable ``find_package()`` call yourself.

.. code-block:: cmake

  # If needed, specify additional components like dot here
  find_package(Doxygen REQUIRED)

  # Pull in cmake-extended-doxygen
  FetchContent_Declare(
      cmake-extended-doxygen
      GIT_REPOSITORY https://github.com/90degs2infty/cmake-extended-doxygen.git
      GIT_TAG main
  )
  FetchContent_MakeAvailable(cmake-extended-doxygen)

  include(ExtendedDoxygen)

This introduces the :variable:`DOXYGEN_GENERATE_DOXYGEN` in your scope.
Additionally, the

* target property :prop_tgt:`GENERATE_DOXYGEN` and the
* source file property :prop_sf:`GENERATE_DOXYGEN`

are made available.

Adding targets to the documentation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now introduce your targets.
To include targets (i.e. their sources) in the documentation, their respective target property :prop_tgt:`GENERATE_DOXYGEN` has to be set to a truthy value.
This can be achieved in several ways:

* Set the variable :variable:`DOXYGEN_GENERATE_DOXYGEN` to some truthy value (``ON``, ``TRUE``, ...).
  Targets that get introduced afterwards will get their :prop_tgt:`GENERATE_DOXYGEN` property initialized with the value in :variable:`DOXYGEN_GENERATE_DOXYGEN` (and consequently be added to the documentation).

  .. code-block:: cmake

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

* Set the target property :prop_tgt:`GENERATE_DOXYGEN` explicitly.

  .. code-block:: cmake

    add_library(
      Bar
      # ...
    )

    set_target_properties(
      Bar
      PROPERTIES
      GENERATE_DOXYGEN ON
    )

For more fine-grained control, there is the additional source file property :prop_sf:`GENERATE_DOXYGEN`.
This property can be used to exclude individual files from the documentation while at the same time including the parent target.

Setting up a target to build the documentation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Once all targets have been introduced, set up a target representing the documentation:

.. code-block:: cmake

  collect_doxygen_input(DOXY_SOURCES DOXY_INCS "${CMAKE_SOURCE_DIR}")

  set(DOXYGEN_STRIP_FROM_INC_PATH "${DOXY_INCS}")
  set(DOXYGEN_USE_MDFILE_AS_MAINPAGE "${CMAKE_SOURCE_DIR}/README.md")

  doxygen_add_documentation(
      Doxygen
      ${DOXY_SOURCES}
      DEDICATED_SOURCES
      "${CMAKE_SOURCE_DIR}/README.md"
  )

See :command:`collect_doxygen_input` as well as :command:`doxygen_add_documentation` for details.

From within the build directory, build the documentation via::

  cmake --build . --target Doxygen
