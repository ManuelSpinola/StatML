#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @import shiny
#' @import bslib
#' @importFrom bsicons bs_icon
#' @importFrom golem add_resource_path bundle_resources favicon with_golem_options
#' @importFrom dplyr filter select mutate arrange desc pull
#' @importFrom ggplot2 ggplot aes geom_point geom_line geom_bar geom_histogram geom_boxplot geom_smooth theme_minimal theme labs scale_color_manual scale_fill_manual element_text
#' @importFrom tidymodels tidymodels_prefer
#' @importFrom rsample initial_split training testing vfold_cv
#' @importFrom recipes recipe step_normalize step_dummy step_zv step_corr all_predictors all_outcomes all_numeric_predictors all_nominal_predictors
#' @importFrom workflows workflow add_recipe add_model fit
#' @importFrom tune tune_grid collect_metrics select_best finalize_workflow last_fit
#' @importFrom parsnip linear_reg logistic_reg rand_forest set_engine set_mode
#' @importFrom yardstick rmse rsq mae accuracy roc_auc f_meas precision recall conf_mat metric_set
#' @importFrom vip vip vi
#' @importFrom ranger ranger
#' @importFrom DT renderDT datatable DTOutput formatRound
#' @importFrom plotly plotlyOutput renderPlotly ggplotly plot_ly layout
#' @importFrom pROC roc auc
#' @importFrom readr read_csv read_delim
#' @importFrom readxl read_excel
## usethis namespace: end
NULL
