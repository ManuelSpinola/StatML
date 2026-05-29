# ============================================================
# golem_utils.R — Utilidades internas de golem para StatML
# ============================================================

#' @noRd
app_sys <- function(...) {
  system.file(..., package = "StatML")
}

#' @noRd
app_prod <- function() {
  isTRUE(get_golem_config("production"))
}
