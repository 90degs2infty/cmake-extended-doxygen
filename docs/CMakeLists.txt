find_program(
    SPHINX_EXECUTABLE
    sphinx-build
    DOC "sphinx executable"
    REQUIRED
)

set(_sphinx_theme default)
set(_sphinx_theme_dir "")
set(_sphinx_source_dir "${CMAKE_CURRENT_LIST_DIR}/src")
set(_sphinx_static_dir "${_sphinx_source_dir}/_static")
set(_sphinx_template_dir "${_sphinx_source_dir}/_templates")
set(_sphinx_build_base_dir "${CMAKE_CURRENT_BINARY_DIR}/sphinx")
set(_sphinx_config_dir "${_sphinx_build_base_dir}/_config")
set(_sphinx_cache_dir "${_sphinx_build_base_dir}/_doctrees")
set(_sphinx_html_dir "${CMAKE_CURRENT_BINARY_DIR}/html")
set(_sphinx_ced_release ${PROJECT_VERSION})

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/conf.py.in"
    "${_sphinx_config_dir}/conf.py"
    @ONLY
)

add_custom_target(
    CED_Documentation # unfortunately :: is not allowed in custom targets' names
    "${SPHINX_EXECUTABLE}"
    -W
    -b html
    -c "${_sphinx_config_dir}"
    -d "${_sphinx_cache_dir}"
    "${_sphinx_source_dir}"
    "${_sphinx_html_dir}"
)

