cmake_policy(SET CMP0118 NEW)

find_package(
    Doxygen
    REQUIRED # make doxygen required
    REQUIRED dot # make dot subcomponent required
)

set(MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

if(NOT MODULE_PATH IN_LIST CMAKE_MODULE_PATH)
    list(APPEND CMAKE_MODULE_PATH ${MODULE_PATH})
endif()
