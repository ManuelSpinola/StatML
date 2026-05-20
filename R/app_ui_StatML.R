#' Application UI
#'
#' @param request shiny request object
#' @export
app_ui <- function(request) {
  tagList(
    golem_add_external_resources(),
    bslib::page_navbar(
      title = tagList(
        tags$span("Stat", style = "font-weight:300;"),
        tags$span("ML",   style = "font-weight:700; color:#2E8B57;")
      ),
      theme = bslib::bs_theme(
        version   = 5,
        bootswatch = "flatly",
        primary   = "#2E8B57",
        font_scale = 0.95
      ),
      lang = "es",

      # ── Módulo 1: Regresión lineal ─────────────────────────────
      bslib::nav_panel(
        title = tagList(bsicons::bs_icon("graph-up", class = "me-1"),
                        "Regresión lineal"),
        mod_lm_ml_ui("lm_ml")
      ),

      # ── Módulo 2: Clasificación GLM ────────────────────────────
      bslib::nav_panel(
        title = tagList(bsicons::bs_icon("diagram-3", class = "me-1"),
                        "Clasificación GLM"),
        mod_glm_ml_ui("glm_ml")
      ),

      # ── Módulo 3: Random Forest Regresión ──────────────────────
      bslib::nav_panel(
        title = tagList(bsicons::bs_icon("tree", class = "me-1"),
                        "RF Regresión"),
        mod_rf_reg_ui("rf_reg")
      ),

      # ── Módulo 4: Random Forest Clasificación ──────────────────
      bslib::nav_panel(
        title = tagList(bsicons::bs_icon("tree-fill", class = "me-1"),
                        "RF Clasificación"),
        mod_rf_clas_ui("rf_clas")
      ),

      # ── Acerca de ──────────────────────────────────────────────
      bslib::nav_panel(
        title = tagList(bsicons::bs_icon("info-circle", class = "me-1"),
                        "Acerca de"),
        mod_acerca_de_ui("acerca_de")
      ),

      bslib::nav_spacer(),
      bslib::nav_item(
        tags$a(
          bsicons::bs_icon("github"),
          href   = "https://github.com/ManuelSpinola/StatML",
          target = "_blank",
          class  = "nav-link"
        )
      )
    )
  )
}

#' @noRd
golem_add_external_resources <- function() {
  add_resource_path("www", app_sys("app/www"))
  tags$head(
    favicon(),
    bundle_resources(path = app_sys("app/www"), app_title = "StatML")
  )
}
