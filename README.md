# cmake-extended-doxygen

## Usage

In the following, `BUILD_DOCUMENTATION` is used as variable to control whether or not to generate documentation.

Early in your `CMakeLists.txt`, pull in `cmake-extended-doxygen` (e.g. via `FetchContent`).

```cmake
if(BUILD_DOCUMENTATION)
    # include(DoxygenIntegration)

    FetchContent_Declare(
        cmake-extended-doxygen
        GIT_REPOSITORY git@github.com:90degs2infty/cmake-extended-doxygen.git
        GIT_TAG master
    )
    FetchContent_MakeAvailable(cmake-extended-doxygen)

    list(APPEND CMAKE_MODULE_PATH /home/davids/workspace/cmake-extended-doxygen/cmake)
    include(ExtendedDoxygen)
endif()
```

From here on, there is a target- and source-level property `GENERATE_DOXYGEN`, the former being initialized from the variable `DOXYGEN_GENERATE_DOXYGEN`.

Introduce your targets.
To include targets (i.e. their sources) in the documentation, use one of the following methods:

- Set the variable `DOXYGEN_GENERATE_DOXYGEN` to some value evaluating to `true`.
  Subsequent targets will get included in the documentation until `DOXYGEN_GENERATE_DOXYGEN` is set to some value evaluating to `false` again.
- Set the target-property `GENERATE_DOXYGEN` to some value evaluating to `true`.

For more fine-grained control, there is the additional source-property `GENERATE_DOXYGEN`.
This property can be used to exclude individual files from the documentation while the parent target is being included at the same time.
For the source-property to have any effect, the parent target has to have `GENERATE_DOXYGEN` enabled (i.e. with the parent target-property being disabled, a given source file will not get documented irrespective of the source-property's value)!

Once all targets have been introduced, make use of doxygen's ordinary CMake-integration:

```cmake
if(BUILD_DOCUMENTATION)
    collect_doxygen_input(DOXY_SOURCES DOXY_INCS "${CMAKE_SOURCE_DIR}")

    set(DOXYGEN_STRIP_FROM_INC_PATH "${DOXY_INCS}")
    doxygen_add_docs(
        Doxygen
        ${DOXY_SOURCES}
    )
endif()
```

From within the build directory, build the documentation via

```bash
cmake --build . --target Doxygen
```

### Per source file `GENERATE_DOXYGEN`

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

See [set_source_file_properties](https://cmake.org/cmake/help/latest/command/set_source_files_properties.html) for details.