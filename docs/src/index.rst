.. cmake-extended-doxygen documentation master file

cmake-extended-doxygen
======================

This repository ships a custom integration of `doxygen <https://doxygen.nl/>`_ into `cmake <https://cmake.org/>`_ built on top of the `default integration shipped with cmake <https://cmake.org/cmake/help/latest/module/FindDoxygen.html>`_.

While the default integration provides the function `doxygen_add_docs <https://cmake.org/cmake/help/latest/module/FindDoxygen.html#command:doxygen_add_docs>`_ to set up a target dedicated to documentation, it does not provide any means to collect ``doxygen``'s input automatically.
This forces the developer into having to manually specify and maintain a list of sources going into documentation as well as a list of include directories to be stripped by ``doxygen``.
Apart from the maintainance overhead, this also leads to redundancies: after all, the set of source files and include directories are already known to ``cmake``, so there should be a way of leveraging this information when specifying ``doxygen``'s input.

To automate the process of collecting ``doxygen``'s input, this repository ships

* the custom target property :prop_tgt:`GENERATE_DOXYGEN` alongside its source file equivalent :prop_sf:`GENERATE_DOXYGEN` to control which source files go into documentation,
* a function :command:`collect_doxygen_input` to automatically populate the list of sources and include directories passed to ``doxygen`` and
* a close-to-drop-in-replacement :command:`doxygen_add_documentation` replacing ``doxygen_add_docs``

Getting started
---------------

.. toctree::
    :hidden:

    getting_started

Please follow :ref:`getting-started`.

Modules
-------

.. toctree::
    :maxdepth: 1
    :caption: Currently, the following modules are shipped:

    module/DoxygenAddDocumentation
    module/ExtendedDoxygen

.. toctree::
    :hidden:

    prop_sf/GenerateDoxygen
    prop_tgt/GenerateDoxygen
    variable/DoxygenGenerateDoxygen

Indices and tables
------------------

* :ref:`genindex`
* :ref:`search`
