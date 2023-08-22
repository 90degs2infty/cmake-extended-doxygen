# cmake-extended-doxygen

> This repository ships a custom integration of [`doxygen`](https://doxygen.nl/) into [`cmake`](https://cmake.org/) built on top of the [default integration shipped with cmake](https://cmake.org/cmake/help/latest/module/FindDoxygen.html).
>
> While the default integration provides the function [`doxygen_add_docs`](https://cmake.org/cmake/help/latest/module/FindDoxygen.html#command:doxygen_add_docs) to set up a target dedicated to documentation, it does not provide any means to collect `doxygen`'s input automatically.
> This forces the developer into having to manually specify and maintain a list of sources going into documentation as well as a list of include directories to be stripped by `doxygen`.
> Apart from the maintainance overhead, this also leads to redundancies:
> after all, the set of source files and include directories are already known to `cmake`, so there should be a way of leveraging this information when specifying `doxygen`'s input.
>
> To automate the process of collecting `doxygen`'s input, this repository ships
>
> - the custom target property [`GENERATE_DOXYGEN`](https://90degs2infty.github.io/cmake-extended-doxygen/prop_tgt/GenerateDoxygen.html#prop_tgt:GENERATE_DOXYGEN) alongside its source file equivalent [`GENERATE_DOXYGEN`](https://90degs2infty.github.io/cmake-extended-doxygen/prop_sf/GenerateDoxygen.html#prop_sf:GENERATE_DOXYGEN) to control which source files go into documentation,
> - the function [`collect_doxygen_input`](https://90degs2infty.github.io/cmake-extended-doxygen/module/ExtendedDoxygen.html#command:collect_doxygen_input) to automatically populate the list of sources and include directories passed to `doxygen` and
> - the function [`doxygen_add_documentation`](https://90degs2infty.github.io/cmake-extended-doxygen/module/DoxygenAddDocumentation.html#command:doxygen_add_documentation) replacing `doxygen_add_docs` (it’s almost a drop-in-replacement).

-- [the docs](https://90degs2infty.github.io/cmake-extended-doxygen/index.html)

For details on using this repository (alongside a [Getting Started guide](https://90degs2infty.github.io/cmake-extended-doxygen/getting_started.html)), please head over to [GitHub Pages](https://90degs2infty.github.io/cmake-extended-doxygen/index.html).

## License

Licensed under [BSD 3-Clause License](LICENSE.md).
