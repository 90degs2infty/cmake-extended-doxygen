# cmake-extended-doxygen

## Usage

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
    collect_doxygen_input(DOXY_SOURCES DOXY_INCS "${CMAKE_SOURCE_DIR}")

    set(DOXYGEN_STRIP_FROM_INC_PATH "${DOXY_INCS}")
    doxygen_add_docs(
        Doxygen
        ${DOXY_SOURCES}
    )
endif()
```
