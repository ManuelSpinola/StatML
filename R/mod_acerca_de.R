# mod_acerca_de.R — Placeholder
#' @noRd
mod_acerca_de_ui <- function(id) {
  ns <- NS(id)
  div(class = "p-3",
    h4("StatML"),
    p("Plataforma interactiva de machine learning."),
    p("Manuel Spínola · ICOMVIS · Universidad Nacional · Costa Rica")
  )
}
#' @noRd
mod_acerca_de_server <- function(id) {
  moduleServer(id, function(input, output, session) {})
}
