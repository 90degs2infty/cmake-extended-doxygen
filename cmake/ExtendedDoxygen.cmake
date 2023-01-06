set(DOXYGEN_GENERATE_DOXYGEN OFF)

define_property(
    TARGET
    PROPERTY GENERATE_DOXYGEN
    INITIALIZE_FROM_VARIABLE DOXYGEN_GENERATE_DOXYGEN
)

define_property(
    SOURCE
    PROPERTY GENERATE_DOXYGEN
    # Note that we do not set this SOURCE property to inherit from the
    # corresponding target property, as source properties chain to DIRECTORY
    # scope instead of TARGET scope.
    # (see the INHERITED option at https://cmake.org/cmake/help/latest/command/define_property.html)
)
