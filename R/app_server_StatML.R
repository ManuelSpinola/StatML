#' Application Server
#'
#' @param input,output,session shiny server arguments
#' @noRd
app_server <- function(input, output, session) {
  mod_lm_ml_server("lm_ml")
  mod_glm_ml_server("glm_ml")
  mod_rf_reg_server("rf_reg")
  mod_rf_clas_server("rf_clas")
  mod_acerca_de_server("acerca_de")
}
