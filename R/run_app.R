#' Run the StatML Shiny Application
#'
#' @param ... arguments to pass to [shiny::shinyApp()]
#'
#' @export
run_app <- function(...) {
  with_golem_options(
    app = shinyApp(
      ui    = app_ui,
      server = app_server
    ),
    golem_opts = list(...)
  )
}
