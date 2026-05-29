# ============================================================
# app_config.R — Configuración global de StatML
# ============================================================

#' @import shiny
#' @importFrom golem get_golem_options
"_PACKAGE"

get_golem_config <- function(
    value,
    config = Sys.getenv("R_CONFIG_ACTIVE", "default"),
    use_parent = TRUE,
    # Modify this if your config file is somewhere else
    file = app_sys("golem-config.yml")
) {
  config::get(
    value = value,
    config = config,
    file = file,
    use_parent = use_parent
  )
}
