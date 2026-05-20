#' Application UI
#'
#' @return A Shiny UI object.
#' @import shiny
#' @import bslib
#' @import bsicons
#' @noRd
app_ui <- function() {

  golem::add_resource_path(
    "www",
    system.file("app/www", package = "StatML")
  )

  bslib::page_navbar(
    title = div(
      style = "display: flex; align-items: center; gap: 10px; margin-top: 4px;",
      img(src = "www/hexsticker_StatML.png", height = "38px"),
      span("StatML", style = "font-weight: 600;")
    ),
    theme = tema_app,
    lang  = "es",
    footer = div(
      class = "text-center text-muted small py-2",
      style = paste0("border-top: 1px solid ", colores$borde, ";"),
      "Manuel Sp\u00ednola \u00b7 ICOMVIS \u00b7 Universidad Nacional \u00b7 Costa Rica"
    ),

    # ── Regresión ─────────────────────────────────────────
    bslib::nav_menu(
      title = "Regresi\u00f3n",
      icon  = bsicons::bs_icon("graph-up"),

      bslib::nav_panel(
        title = "Regresi\u00f3n lineal (LM)",
        icon  = bsicons::bs_icon("graph-up"),
        mod_lm_ml_ui("lm_ml")
      ),

      bslib::nav_panel(
        title = "Random Forest",
        icon  = bsicons::bs_icon("tree"),
        mod_rf_reg_ui("rf_reg")
      )
    ),

    # ── Clasificación ─────────────────────────────────────
    bslib::nav_menu(
      title = "Clasificaci\u00f3n",
      icon  = bsicons::bs_icon("diagram-3"),

      bslib::nav_panel(
        title = "Clasificaci\u00f3n GLM",
        icon  = bsicons::bs_icon("diagram-3"),
        mod_glm_ml_ui("glm_ml")
      ),

      bslib::nav_panel(
        title = "Random Forest",
        icon  = bsicons::bs_icon("tree-fill"),
        mod_rf_clas_ui("rf_clas")
      )
    ),

    bslib::nav_spacer(),

    bslib::nav_panel(
      title = "Acerca de",
      icon  = bsicons::bs_icon("info-circle"),
      mod_acerca_de_ui("acerca_de")
    ),

    bslib::nav_item(
      tags$span(class = "text-white-50 small", "StatML v0.0.1")
    )
  )
}
