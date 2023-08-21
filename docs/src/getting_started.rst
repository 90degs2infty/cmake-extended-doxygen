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
