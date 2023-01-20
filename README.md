# cmake-extended-doxygen

A target-based integration of [Doxygen](https://doxygen.nl/) into [CMake](https://cmake.org/).

## Why this integration?

This repository ships a custom integration of Doxygen into CMake build on top of the [default integration shipped with CMake](https://cmake.org/cmake/help/latest/module/FindDoxygen.html).

While the default Doxygen integration provides the function [`doxygen_add_docs`](https://cmake.org/cmake/help/latest/module/FindDoxygen.html#command:doxygen_add_docs) to set up a target dedicated to documentation, it does not provide any means to collect Doxygen's input automatically.
This forces the developer having to manually specify and maintain a list of sources going into documentation as well as a list of include directories to be stripped by Doxygen.
Apart from the maintainance overhead, this also leads to redundancies: after all, the set of source files and include directories are already known to CMake, so there should be a way of leveraging this information when specifying Doxygen's input.

To automate the process setting up Doxygen's input, this repository ships:

- a custom marker property `GENERATE_DOXYGEN` (target and source-file level) to control which source files go into documentation
- a function `collect_doxygen_input` to automatically populate the list of sources and include directories passed to Doxygen
- a close-to-drop-in-replacement `doxygen_add_documentation` superseeding `doxygen_add_docs`

## Usage

### Prerequisites

- CMake >= 3.20
  - Policies [`CMP0115`](https://cmake.org/cmake/help/latest/policy/CMP0015.html) and [`CMP0118`](https://cmake.org/cmake/help/latest/policy/CMP0118.html) have to be set to `NEW`, i.e. source file extensions have to be specified explicitly and the `GENERATED` source file property should be visible from all directories.
- Doxygen

### Getting `cmake-extended-doxygen`

Early in your `CMakeLists.txt`, pull in `cmake-extended-doxygen` (e.g. via `FetchContent`).
This has to be done before you start introducing your targets, as otherwise your targets will lack the `GENERATE_DOXYGEN` property.

```cmake
# If needed, specify additional components like dot here
find_package(Doxygen REQUIRED)

# Pull in cmake-extended-doxygen
FetchContent_Declare(
    cmake-extended-doxygen
    GIT_REPOSITORY git@github.com:90degs2infty/cmake-extended-doxygen.git
    GIT_TAG master
)
FetchContent_MakeAvailable(cmake-extended-doxygen)

list(APPEND CMAKE_MODULE_PATH /home/davids/workspace/cmake-extended-doxygen/cmake)
include(ExtendedDoxygen)
```

This introduces a target- and source-level property `GENERATE_DOXYGEN`, the former being initialized from the variable `DOXYGEN_GENERATE_DOXYGEN`.

### Adding targets to the documentation

Now introduce your targets.
To include targets (i.e. their sources) in the documentation, use one of the following methods:

- Set the variable `DOXYGEN_GENERATE_DOXYGEN` to some value evaluating to `TRUE`.

  ```cmake
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
  ```

  Subsequent targets will all get included in the documentation until `DOXYGEN_GENERATE_DOXYGEN` is set to some value evaluating to `FALSE` again.
- Set the target-property `GENERATE_DOXYGEN` to some value evaluating to `true`.

  ```cmake
  add_library(
    Bar
    # ...
  )

  set_target_properties(
    Bar
    PROPERTIES
    GENERATE_DOXYGEN ON
  )
  ```

For more fine-grained control, there is the additional source-property `GENERATE_DOXYGEN`.
This property can be used to exclude individual files from the documentation while at the same time including the parent target.
For the source-property to have any effect, the parent target has to have `GENERATE_DOXYGEN` enabled (i.e. with the parent target-property being disabled, a given source file will not get documented irrespective of the source-property's value)!

### Introducing the documentation to CMake

Once all targets have been introduced, set up a target representing the documenation:

```cmake
collect_doxygen_input(DOXY_SOURCES DOXY_INCS "${CMAKE_SOURCE_DIR}")

set(DOXYGEN_STRIP_FROM_INC_PATH "${DOXY_INCS}")
set(DOXYGEN_USE_MDFILE_AS_MAINPAGE "${CMAKE_SOURCE_DIR}/README.md")

doxygen_add_documentation(
    Doxygen
    ${DOXY_SOURCES}
    DEDICATED_SOURCES
    "${CMAKE_SOURCE_DIR}/README.md"
)
```

From within the build directory, build the documentation via

```bash
cmake --build . --target Doxygen
```

## Reference

### Target property `GENERATE_DOXYGEN`

Marker property to specify which targets go into documentation.
See [Adding targets to the documentation](#adding-targets-to-the-documentation) for details on usage.

### Source file property `GENERATE_DOXYGEN`

Marker property to exclude source files from documentation while the parent target is included in documentation.
See [Adding targets to the documentation](#adding-targets-to-the-documentation) for details on usage.

The source file property `GENERATE_DOXYGEN` has to be visible in the parent target's directory scope.
By default, this is the case if the property is being set in the same `CMakeLists.txt` that introduces the target.
For more complex source layouts (as recommended by the CMake docs), consider the following example.

Given some library `libfoo` in directory `foo` with the source files living in subdirectory `src`.
Then set `GENERATE_DOXYGEN` as follows:

```cmake
# ./foo/CMakeLists.txt

add_library(
    foo
)

set_target_properties(
    foo
    PROPERTIES
    GENERATE_DOXYGEN ON
)
```

```cmake
# ./foo/src/CMakeLists.txt

target_sources(
    foo
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/bar.cpp
    # ...
)

set_source_files_properties(
    ${CMAKE_CURRENT_SOURCE_DIR}/bar.cpp
    TARGET_DIRECTORY foo # extend visibility of below property
    PROPERTIES
    GENERATE_DOXYGEN OFF
)
```

See [set_source_file_properties](https://cmake.org/cmake/help/latest/command/set_source_files_properties.html) for details on visibility.

### `collect_doxygen_input`

Function to collect source files alongside include directories to be passed to Doxygen.

Signature:

```cmake
collect_doxygen_input(VAR_SOURCES VAR_INCLUDE_DIRS DIR)
```

This function recursively collects all doxygen-relevant source files and include directories of targets defined at or below the specified directory `DIR`.
The resulting lists of sources and include directories are written to the variables `VAR_SOURCES` and `VAR_INCLUDE_DIRS` respectively.

Source files are considered doxygen-relevant, if the parent target's property `GENERATE_DOXYGEN` is set to some value evaluating to `TRUE`.
This can be overriden by the source file's property `GENERATE_DOXYGEN` (see [Source file property `GENERATE_DOXYGEN`](#source-file-property-generate_doxygen) for details).

The list of include directories is populated from the iterated targets' property [`INTERFACE_INCLUDE_DIRECTORIES`](https://cmake.org/cmake/help/latest/prop_tgt/INTERFACE_INCLUDE_DIRECTORIES.html).

### `doxygen_add_documentation`

> This function is intended as a convenience for adding a target for generating documentation with Doxygen. [Source](https://cmake.org/cmake/help/latest/module/FindDoxygen.html#command:doxygen_add_docs)

See [CMake's docs on `doxygen_add_docs`](https://cmake.org/cmake/help/latest/module/FindDoxygen.html#command:doxygen_add_docs) for general advice on how to use `doxygen_add_documentation`.

`doxygen_add_documentation` is intended as drop-in-replacement for `doxygen_add_docs` (at least mostly).
The former differs from the latter in the following ways:

- The `Doxyfile` configuration file is generated at generation time (in contrast to at configure time) to allow for substitution of [generator expressions](https://cmake.org/cmake/help/latest/manual/cmake-generator-expressions.7.html).
  This is needed to allow for generator expressions in source file paths as well as include directories.
- Sources specified as positional arguments do not get passed as [`SOURCES`](https://cmake.org/cmake/help/latest/command/add_custom_target.html) argument to the constructed custom target.
  Sources specified as positional arguments are considered to be part of some other target, hence they do not get passed on.
  To explicitly pass sources to the constructed custom target, consider using the additional keyword argument `DEDICATED_SOURCES`.
- An additional keyword argument `DEDICATED_SOURCES` is supported.
  This keyword argument accepts a list of sources, which are dedicated at the constructed custom target itself.
  Sources passed this way get passed on to the constructed custom target as `SOURCES`.
  A common use-case is the specification of some `README.md`, which does not contribute code to the code base but gets passed to Doxygen via `DOXYGEN_USE_MDFILE_AS_MAINPAGE`.

## Implementation details

TBA

## Known issues

TBA
