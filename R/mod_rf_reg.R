# ============================================================
# mod_rf_reg.R — Random Forest Regresión
# StatML · StatSuite
# Manuel Spínola · ICOMVIS · UNA · Costa Rica
# ============================================================

# ── UI ──────────────────────────────────────────────────────
#' @noRd
mod_rf_reg_ui <- function(id) {
  ns <- NS(id)

  tagList(
    bslib::navset_card_tab(
      id = ns("tabs"),

      # PESTAÑA 1: ¿Qué es?
      # ════════════════════════════════════════════════
      bslib::nav_panel(
        title = "¿Qué es?",
        icon  = bsicons::bs_icon("question-circle"),
        div(class = "p-3",
          fluidRow(
            column(8,
              h4(tagList(bsicons::bs_icon("tree", class = "me-2"),
                         "Random Forest para Regresión")),
              p(class = "lead",
                "Random Forest es un conjunto (", em("ensemble"), ") de ",
                strong("árboles de decisión"), " entrenados en paralelo.
                 Antes de entender Random Forest es necesario entender
                 cómo funciona un árbol de decisión."),
              hr(),
              h5(tagList(bsicons::bs_icon("diagram-2", class = "me-1"),
                         "Árbol de decisión")),
              p(class = "small",
                "Un árbol de decisión divide el espacio de predictores en regiones
                 rectangulares mediante preguntas del tipo ", em("¿X > umbral?"),
                " En cada nodo terminal (hoja) se predice el ",
                strong("promedio de Y"), " de las observaciones en esa región.",
                " Son intuitivos pero inestables: pequeños cambios en los datos
                 pueden producir árboles muy diferentes."),
              hr(),
              h5(tagList(bsicons::bs_icon("tree-fill", class = "me-1"),
                         "De un árbol a Random Forest")),
              p(class = "small",
                "Random Forest resuelve la inestabilidad del árbol individual
                 entrenando ", strong("muchos árboles"), " sobre muestras bootstrap
                 y promediando sus predicciones. La aleatoriedad adicional en la
                 selección de variables (", strong("mtry"), ") reduce la correlación
                 entre árboles y mejora la generalización."),
              br(),
              fluidRow(
                column(6,
                  div(class = "card mb-3",
                    div(class = "card-header",
                        tagList(bsicons::bs_icon("1-circle"), " Bootstrap")),
                    div(class = "card-body",
                      p(class = "small",
                        "Se generan ", strong("B muestras bootstrap"),
                        " del mismo tamaño que el original pero con reemplazo. Aproximadamente el ",
                        strong("63% de las observaciones únicas"), " son seleccionadas en cada muestra.
                         El ", strong("37% restante"), " — las no seleccionadas — forman el conjunto ",
                        strong("Out-of-Bag (OOB)"),
                        " que permite estimar el error sin necesidad de un conjunto de validación separado.")
                    )
                  )
                ),
                column(6,
                  div(class = "card mb-3",
                    div(class = "card-header",
                        tagList(bsicons::bs_icon("2-circle"), " Árboles aleatorios")),
                    div(class = "card-body",
                      p(class = "small",
                        "Se ajusta un árbol en cada muestra. En cada división solo
                         se consideran ", strong("mtry variables aleatorias"),
                        ". Esto decorrelaciona los árboles.")
                    )
                  )
                )
              ),
              fluidRow(
                column(6,
                  div(class = "card mb-3",
                    div(class = "card-header",
                        tagList(bsicons::bs_icon("3-circle"), " Agregación")),
                    div(class = "card-body",
                      p(class = "small",
                        "La predicción final es el ", strong("promedio"),
                        " de los B árboles. Para regresión: ŷ = (1/B) Σ ŷ_b")
                    )
                  )
                ),
                column(6,
                  div(class = "card mb-3",
                    div(class = "card-header",
                        tagList(bsicons::bs_icon("graph-up-arrow"), " Ventaja sobre LM")),
                    div(class = "card-body",
                      p(class = "small",
                        "Captura relaciones ", strong("no lineales"),
                        " e interacciones entre variables sin necesidad de
                         especificarlas. Robusto a outliers y variables irrelevantes.")
                    )
                  )
                )
              )
            ),
            column(4,
              div(class = "card mb-3",
                div(class = "card-header",
                    tagList(bsicons::bs_icon("list-check"), " En este módulo")),
                div(class = "card-body",
                  tags$ol(
                    tags$li("Cargar y explorar datos"),
                    tags$li("Preprocesar variables"),
                    tags$li("Tuning de hiperparámetros (CV)"),
                    tags$li("Ajustar modelo final"),
                    tags$li("Evaluar performance"),
                    tags$li("Comparar con LM"),
                    tags$li("Interpretar importancia y PDP")
                  )
                )
              ),
              div(class = "card",
                div(class = "card-header",
                    tagList(bsicons::bs_icon("sliders"), " Hiperparámetros clave")),
                div(class = "card-body",
                  tags$dl(
                    tags$dt("trees"),
                    tags$dd(class = "small text-muted",
                      "Número de árboles (B). Más árboles = más estable.
                       Típicamente 500–1000."),
                    tags$dt("mtry"),
                    tags$dd(class = "small text-muted",
                      "Variables candidatas en cada división. Default: p/3 para regresión."),
                    tags$dt("min_n"),
                    tags$dd(class = "small text-muted",
                      "Mínimo de observaciones por nodo. Controla la profundidad del árbol.")
                  )
                )
              )
            )
          )
        )
      ), # /PESTAÑA 1

      # PESTAÑA 2: Fundamentos
      # ════════════════════════════════════════════════
      bslib::nav_panel(
        title = "Fundamentos",
        icon  = bsicons::bs_icon("book"),
        div(class = "p-3",
          bslib::navset_pill(

            bslib::nav_panel("Train / Validación / Test",
              br(),
              p("Con tuning de hiperparámetros necesitamos ", strong("tres conjuntos"),
                " para evitar fuga de información:"),
              br(),
              div(style = "max-width: 700px;",
                div(style = "display: flex; height: 60px; border-radius: 8px; overflow: hidden; border: 1px solid #C8D9EC;",
                  div(style = "background: #1170AA; width: 64%; display: flex; align-items: center; justify-content: center;",
                    span(style = "color: #ffffff; font-weight: 700;", "Entrenamiento (64%)")
                  ),
                  div(style = "background: #FC7D0B; width: 16%; display: flex; align-items: center; justify-content: center;",
                    span(style = "color: #ffffff; font-weight: 700; font-size: 0.85rem;", "Val. (16%)")
                  ),
                  div(style = "background: #C85200; width: 20%; display: flex; align-items: center; justify-content: center;",
                    span(style = "color: #ffffff; font-weight: 700;", "Prueba (20%)")
                  )
                ),
                br(),
                fluidRow(
                  column(4,
                    div(style = "border-left: 4px solid #1170AA; padding-left: 0.8rem;",
                      p(class = "mb-1", strong(style = "color:#1170AA;", "Entrenamiento")),
                      p(class = "small text-muted mb-0",
                        "El modelo aprende los patrones. Se usa en cada fold de CV.")
                    )
                  ),
                  column(4,
                    div(style = "border-left: 4px solid #FC7D0B; padding-left: 0.8rem;",
                      p(class = "mb-1", strong(style = "color:#FC7D0B;", "Validación (CV)")),
                      p(class = "small text-muted mb-0",
                        "Selecciona los mejores hiperparámetros. Parte del train, rotada en CV.")
                    )
                  ),
                  column(4,
                    div(style = "border-left: 4px solid #C85200; padding-left: 0.8rem;",
                      p(class = "mb-1", strong(style = "color:#C85200;", "Prueba")),
                      p(class = "small text-muted mb-0",
                        "Evaluación final honesta. Se usa una sola vez al final.")
                    )
                  )
                )
              )
            ),

            bslib::nav_panel("Métricas",
              br(),
              fluidRow(
                column(4,
                  div(class = "metrica-card",
                    div(class = "metrica-label", "RMSE"),
                    div(class = "metrica-valor", "√MSE"),
                    p(class = "small mt-2",
                      "Error cuadrático medio. Mismas unidades que Y. Penaliza errores grandes.")
                  )
                ),
                column(4,
                  div(class = "metrica-card",
                    div(class = "metrica-label", "R²"),
                    div(class = "metrica-valor", "0–1"),
                    p(class = "small mt-2",
                      "Proporción de varianza explicada. Comparable entre modelos.")
                  )
                ),
                column(4,
                  div(class = "metrica-card",
                    div(class = "metrica-label", "MAE"),
                    div(class = "metrica-valor", "mean|e|"),
                    p(class = "small mt-2",
                      "Error absoluto medio. Más robusto a outliers que RMSE.")
                  )
                )
              )
            ),

            bslib::nav_panel("Overfitting",
              br(),
              p("El overfitting ocurre cuando el modelo memoriza el conjunto de entrenamiento
                 pero generaliza mal a datos nuevos. Es especialmente relevante en RF con
                 árboles muy profundos."),
              br(),
              fluidRow(
                column(4,
                  div(class = "card sem-ok",
                    div(class = "card-body",
                      h6(bsicons::bs_icon("check-circle"), " Buen ajuste"),
                      p(class = "small mb-0",
                        "RMSE train ≈ RMSE test. El modelo generaliza bien.")
                    )
                  )
                ),
                column(4,
                  div(class = "card sem-bad",
                    div(class = "card-body",
                      h6(bsicons::bs_icon("x-circle"), " Overfitting"),
                      p(class = "small mb-0",
                        "RMSE train << RMSE test. El modelo memorizó el training set.")
                    )
                  )
                ),
                column(4,
                  div(class = "card sem-warn",
                    div(class = "card-body",
                      h6(bsicons::bs_icon("exclamation-triangle"), " Underfitting"),
                      p(class = "small mb-0",
                        "RMSE train ≈ RMSE test pero ambos altos. Modelo demasiado simple.")
                    )
                  )
                )
              ),
              br(),
              p("El tuning con CV ayuda a encontrar hiperparámetros que eviten el overfitting
                 seleccionando el modelo con mejor RMSE en validación, no en entrenamiento.")
            ),

            bslib::nav_panel("Hiperparámetros",
              br(),
              fluidRow(
                column(4,
                  div(class = "card",
                    div(class = "card-header", strong("trees")),
                    div(class = "card-body",
                      p(class = "small",
                        "Número de árboles en el bosque. A partir de ~500 el error
                         se estabiliza. Aumentarlo no causa overfitting pero sí aumenta
                         el tiempo de cómputo."),
                      div(style = "background:#f8f9fa; border-radius:6px; padding:0.5rem; font-size:0.8rem;",
                        "Rango típico: 100 – 1000", br(),
                        "Default ranger: 500")
                    )
                  )
                ),
                column(4,
                  div(class = "card",
                    div(class = "card-header", strong("mtry")),
                    div(class = "card-body",
                      p(class = "small",
                        "Número de variables candidatas en cada división del árbol.
                         Valor bajo → árboles más diversos (menos correlacionados).
                         Valor alto → árboles más similares a un árbol completo."),
                      div(style = "background:#f8f9fa; border-radius:6px; padding:0.5rem; font-size:0.8rem;",
                        "Default regresión: floor(p/3)", br(),
                        "Rango: 1 – p")
                    )
                  )
                ),
                column(4,
                  div(class = "card",
                    div(class = "card-header", strong("min_n")),
                    div(class = "card-body",
                      p(class = "small",
                        "Mínimo de observaciones requeridas para dividir un nodo.
                         Valor alto → árboles menos profundos → menos overfitting.
                         Valor bajo → árboles más profundos → más flexible."),
                      div(style = "background:#f8f9fa; border-radius:6px; padding:0.5rem; font-size:0.8rem;",
                        "Default: 5 (regresión)", br(),
                        "Rango: 1 – 40")
                    )
                  )
                )
              )
            )
          )
        )
      ), # /PESTAÑA 2

      # PESTAÑA 3: Los datos
      # ════════════════════════════════════════════════
      bslib::nav_panel(
        title = "Los datos",
        icon  = bsicons::bs_icon("table"),
        bslib::card_body(
          bslib::navset_pill(

            bslib::nav_panel(
              title = tagList(bsicons::bs_icon("database", class = "me-1"), "Cargar datos"),
              br(),
              bslib::layout_columns(
                col_widths = c(4, 8),
                bslib::card(
                  bslib::card_header(bsicons::bs_icon("folder2-open", class = "me-1"),
                                     "Fuente de datos"),
                  bslib::card_body(
                    style = "overflow: visible; height: auto;",
                    radioButtons(ns("fuente_datos"),
                      label   = tagList(bsicons::bs_icon("database", class = "me-1"),
                                        "Datos de ejemplo:"),
                      choices = c(
                        "Densidad de aves (paisaje)"          = "aves_densidad_paisaje",
                        "Abundancia de aves (paisaje)"         = "aves_conteo_paisaje",
                        "Biomasa forestal"                    = "biomasa_paisaje",
                        "Talla de cangrejo violinista"         = "pie_crab",
                        "Sacramento (precios de casas)"       = "sacramento",
                        "Calidad de vino tinto"               = "winequality_red",
                        "Cargar mis propios datos"            = "propio"
                      ),
                      selected = "aves_densidad_paisaje"
                    ),
                    tags$hr(),
                    fileInput(ns("archivo_datos"),
                      label       = "Seleccionar archivo:",
                      accept      = c(".csv", ".xlsx", ".xls"),
                      buttonLabel = "Buscar\u2026",
                      placeholder = "CSV o Excel"
                    ),
                    selectInput(ns("separador"),
                      label    = "Separador (CSV):",
                      choices  = c("Coma (,)" = ",", "Punto y coma (;)" = ";",
                                   "Tabulador" = "\t"),
                      selected = ","
                    ),
                    p(class = "small text-muted mb-0",
                      bsicons::bs_icon("info-circle", class = "me-1"),
                      "La primera fila debe contener los nombres de las columnas."),
                    tags$hr(),
                    uiOutput(ns("info_dataset"))
                  )
                ),
                bslib::card(
                  bslib::card_header(bsicons::bs_icon("eye", class = "me-1"), "Vista previa"),
                  bslib::card_body(
                    style = "overflow: auto;",
                    uiOutput(ns("metricas_datos")),
                    br(),
                    DT::DTOutput(ns("tabla_vista_previa"))
                  )
                )
              )
            ),

            bslib::nav_panel(
              title = tagList(bsicons::bs_icon("sliders2", class = "me-1"),
                              "Tipos de variables"),
              br(),
              p(class = "small text-muted mb-3",
                "Verifica que cada variable tenga el tipo correcto. ",
                "Las variables ", strong("categ\u00f3ricas"),
                " deben ser ", strong("Factor"), ". ",
                "Las variables codificadas como n\u00fameros pero que ",
                "representan grupos deben cambiarse a Factor antes de modelar."
              ),
              bslib::layout_columns(
                col_widths = c(10, 2),
                uiOutput(ns("tabla_tipos")),
                div(
                  class = "pt-2",
                  actionButton(ns("aplicar_tipos"), "Aplicar tipos",
                               class = "btn-primary w-100",
                               icon = shiny::icon("check")),
                  br(), br(),
                  actionButton(ns("resetear_tipos"), "Restaurar",
                               class = "btn-outline-secondary w-100 btn-sm",
                               icon = shiny::icon("rotate-left"))
                )
              ),
              uiOutput(ns("tipos_aplicados_msg"))
            )
          )
        )
      ), # /PESTAÑA 3

      # PESTAÑA 4: Explorar
      # ════════════════════════════════════════════════
      bslib::nav_panel(
        title = "Explorar",
        icon  = bsicons::bs_icon("search"),
        div(class = "p-3",
          fluidRow(
            column(4,
              div(class = "card",
                div(class = "card-header", "Opciones"),
                div(class = "card-body",
                  uiOutput(ns("sel_var_resp_explorar")),
                  uiOutput(ns("sel_var_x_explorar")),
                  selectInput(ns("tipo_grafico_explorar"),
                    label   = "Tipo de gráfico",
                    choices = c("Dispersión"  = "scatter",
                                "Histograma"  = "hist",
                                "Boxplot"     = "boxplot",
                                "Correlación" = "corr")
                  ),
                  uiOutput(ns("sel_color_explorar"))
                )
              )
            ),
            column(8,
              plotly::plotlyOutput(ns("plot_explorar"), height = "450px")
            )
          ),
          br(),
          fluidRow(
            column(12,
              h5("Resumen estadístico"),
              DT::DTOutput(ns("tabla_resumen_explorar"))
            )
          )
        )
      ), # /PESTAÑA 4

      # PESTAÑA 5: Preprocesamiento
      # ════════════════════════════════════════════════
      bslib::nav_panel(
        title = "Preprocesamiento",
        icon  = bsicons::bs_icon("gear"),
        div(class = "p-3",
          fluidRow(
            column(4,
              div(class = "card mb-3",
                div(class = "card-header", "Variable respuesta"),
                div(class = "card-body",
                  uiOutput(ns("sel_var_respuesta"))
                )
              ),
              div(class = "card mb-3",
                div(class = "card-header", "Predictores"),
                div(class = "card-body",
                  uiOutput(ns("sel_predictores"))
                )
              ),
              div(class = "card mb-3",
                div(class = "card-header", "División train/test"),
                div(class = "card-body",
                  sliderInput(ns("prop_train"),
                    label = "Proporción entrenamiento",
                    min = 0.5, max = 0.9, value = 0.8, step = 0.05,
                    post = "%"
                  ),
                  numericInput(ns("semilla"),
                    label = "Semilla",
                    value = 123, min = 1, step = 1
                  )
                )
              ),
              div(class = "card",
                div(class = "card-header", "Pasos de la receta"),
                div(class = "card-body",
                  checkboxInput(ns("step_dummy"),
                    "Variables dummy (categóricas)", value = TRUE),
                  checkboxInput(ns("step_zv"),
                    "Eliminar varianza cero", value = TRUE)
                )
              )
            ),
            column(8,
              uiOutput(ns("resumen_preprocesamiento"))
            )
          )
        )
      ), # /PESTAÑA 5

      # PESTAÑA 6: Ajustar modelo
      # ════════════════════════════════════════════════
      bslib::nav_panel(
        title = "Ajustar modelo",
        icon  = bsicons::bs_icon("play-circle"),
        div(class = "p-3",
          fluidRow(
            column(4,
              div(class = "card mb-3",
                div(class = "card-header", "Hiperparámetros"),
                div(class = "card-body",
                  p(class = "small text-muted mb-3",
                    "Define los rangos para el grid search. La CV seleccionará
                     automáticamente la mejor combinación."),
                  sliderInput(ns("trees_range"),
                    label = "trees (número de árboles)",
                    min = 100, max = 1000, value = c(200, 800), step = 100
                  ),
                  sliderInput(ns("mtry_range"),
                    label = "mtry (variables por división)",
                    min = 1, max = 10, value = c(2, 6), step = 1
                  ),
                  sliderInput(ns("min_n_range"),
                    label = "min_n (mínimo por nodo)",
                    min = 1, max = 40, value = c(2, 20), step = 1
                  ),
                  numericInput(ns("cv_folds_tuning"),
                    label = "Folds para tuning CV",
                    value = 5, min = 3, max = 10, step = 1
                  ),
                  numericInput(ns("grid_size"),
                    label = "Tamaño del grid",
                    value = 10, min = 5, max = 30, step = 5
                  )
                )
              ),
              div(class = "card",
                div(class = "card-header", "Acciones"),
                div(class = "card-body",
                  actionButton(ns("btn_tuning"),
                    label = tagList(bsicons::bs_icon("search"), " Buscar hiperparámetros"),
                    class = "btn-outline-primary w-100 mb-2"
                  ),
                  actionButton(ns("btn_ajustar"),
                    label = tagList(bsicons::bs_icon("play-fill"), " Ajustar modelo final"),
                    class = "btn-primary w-100"
                  ),
                  br(),
                  uiOutput(ns("estado_modelo"))
                )
              )
            ),
            column(8,
              uiOutput(ns("resumen_tuning")),
              br(),
              uiOutput(ns("resumen_modelo"))
            )
          )
        )
      ), # /PESTAÑA 6

      # PESTAÑA 7: Diagnóstico
      # ════════════════════════════════════════════════
      bslib::nav_panel(
        title = "Diagnóstico",
        icon  = bsicons::bs_icon("clipboard2-pulse"),
        div(class = "p-3",
          p(class = "small text-muted mb-3",
            "A diferencia de LM, RF no asume distribución de residuos.
             El diagnóstico se centra en detectar patrones sistemáticos
             en los residuos que indiquen problemas de ajuste."),
          fluidRow(
            column(6,
              h6("Residuos vs Valores ajustados"),
              plotly::plotlyOutput(ns("plot_resid_fitted"), height = "300px")
            ),
            column(6,
              h6("Distribución de residuos"),
              plotly::plotlyOutput(ns("plot_resid_hist"), height = "300px")
            )
          ),
          br(),
          fluidRow(
            column(6,
              h6("Residuos vs Índice (orden)"),
              plotly::plotlyOutput(ns("plot_resid_index"), height = "300px")
            ),
            column(6,
              h6("Out-of-Bag (OOB) error"),
              plotly::plotlyOutput(ns("plot_oob"), height = "300px")
            )
          )
        )
      ), # /PESTAÑA 7

      # PESTAÑA 8: Performance
      # ════════════════════════════════════════════════
      bslib::nav_panel(
        title = "Performance",
        icon  = bsicons::bs_icon("speedometer2"),
        div(class = "p-3",

          div(style = "border-left: 4px solid #1170AA; padding-left: 1rem; margin-bottom: 1.5rem;",
            h4(style = "color: #1170AA; font-weight: 700; margin-bottom: 0.2rem;",
               bsicons::bs_icon("diagram-2", class = "me-2"), "Hold-out (Train / Test)"),
            p(class = "small text-muted mb-3",
              "El modelo final se entrena con el ", strong("conjunto de entrenamiento"),
              " y se evalúa con el ", strong("conjunto de prueba."))
          ),
          fluidRow(
            column(4, uiOutput(ns("card_rmse_train"))),
            column(4, uiOutput(ns("card_rmse_test"))),
            column(4, uiOutput(ns("semaforo_performance")))
          ),
          br(),
          fluidRow(
            column(4, uiOutput(ns("card_rsq_train"))),
            column(4, uiOutput(ns("card_rsq_test")))
          ),

          hr(),

          div(style = "border-left: 4px solid #FC7D0B; padding-left: 1rem; margin-bottom: 1.5rem;",
            h4(style = "color: #FC7D0B; font-weight: 700; margin-bottom: 0.2rem;",
               bsicons::bs_icon("arrow-repeat", class = "me-2"),
               "Validación cruzada — Tuning"),
            p(class = "small text-muted mb-0",
              "Métricas del grid search. Cada fila es una combinación de hiperparámetros
               evaluada por CV.")
          ),
          uiOutput(ns("tabla_tuning_performance"))
        )
      ), # /PESTAÑA 8

      # PESTAÑA 9: Predicciones
      # ════════════════════════════════════════════════
      bslib::nav_panel(
        title = "Predicciones",
        icon  = bsicons::bs_icon("crosshair"),
        div(class = "p-3",
          fluidRow(
            column(8,
              h6("Valores observados vs predichos (datos de prueba)"),
              plotly::plotlyOutput(ns("plot_obs_pred"), height = "400px")
            ),
            column(4,
              h6("Distribución de residuos"),
              plotly::plotlyOutput(ns("plot_resid_dist"), height = "400px")
            )
          ),
          br(),
          fluidRow(
            column(12,
              h5("Tabla de predicciones (datos de prueba)"),
              DT::DTOutput(ns("tabla_predicciones"))
            )
          )
        )
      ), # /PESTAÑA 9

      # PESTAÑA 10: Importancia
      # ════════════════════════════════════════════════
      bslib::nav_panel(
        title = "Importancia",
        icon  = bsicons::bs_icon("bar-chart-line"),
        div(class = "p-3",
          fluidRow(
            column(8,
              h6("Importancia de variables"),
              p(class = "small text-muted",
                "Importancia por permutación: se permuta cada variable aleatoriamente
                 y se mide el aumento en RMSE. Método agnóstico — comparable entre LM y RF."),
              plotly::plotlyOutput(ns("plot_importancia"), height = "400px")
            ),
            column(4,
              h6("Tabla de importancia"),
              DT::DTOutput(ns("tabla_importancia"))
            )
          )
        )
      ), # /PESTAÑA 10

      # PESTAÑA 11: PDP
      # ════════════════════════════════════════════════
      bslib::nav_panel(
        title = "PDP",
        icon  = bsicons::bs_icon("bar-chart-steps"),
        div(class = "p-3",
          p(class = "small text-muted mb-3",
            "Los Partial Dependence Plots (PDP) muestran el efecto marginal de cada
             predictor sobre la variable respuesta, promediando sobre los demás.
             En RF capturan relaciones no lineales e interacciones."),
          fluidRow(
            column(4,
              div(class = "card",
                div(class = "card-header", "Opciones"),
                div(class = "card-body",
                  uiOutput(ns("sel_var_pdp")),
                  sliderInput(ns("grid_pdp"), "Puntos de la grilla",
                              min = 10, max = 50, value = 20, step = 5)
                )
              )
            ),
            column(8,
              plotly::plotlyOutput(ns("plot_pdp"), height = "400px")
            )
          )
        )
      ), # /PESTAÑA 11

      # PESTAÑA 12: Código R
      # ════════════════════════════════════════════════
      bslib::nav_panel(
        title = "Código R",
        icon  = bsicons::bs_icon("code-slash"),
        div(class = "p-3",
          p(class = "small text-muted mb-3",
            "Código R reproducible para ejecutar el análisis completo fuera de StatML."),
          div(class = "codigo-bloque",
            verbatimTextOutput(ns("codigo_reproducible"))
          ),
          br(),
          downloadButton(ns("btn_descargar_codigo"),
            label = tagList(bsicons::bs_icon("download"), " Descargar script .R"),
            class = "btn-outline-primary"
          )
        )
      ) # /PESTAÑA 12

    ) # /navset_card_tab
  ) # /tagList
} # /mod_rf_reg_ui

# ── SERVER ───────────────────────────────────────────────────
#' @noRd
mod_rf_reg_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # PESTAÑA 3: Los datos
    # ════════════════════════════════════════════════

    tipos_usuario <- reactiveVal(NULL)
    observeEvent(input$fuente_datos, { tipos_usuario(NULL) })
    observeEvent(input$resetear_tipos, {
      tipos_usuario(NULL)
      showNotification("Tipos restaurados.", type = "message", duration = 2)
    })
    observeEvent(input$aplicar_tipos, {
      df  <- datos_raw(); req(df)
      nms <- names(df)
      nuevos <- lapply(nms, function(nm) input[[paste0("tipo_", nm)]])
      names(nuevos) <- nms
      tipos_usuario(nuevos)
      showNotification("Tipos aplicados.", type = "message", duration = 2)
    })

    datos_raw <- reactive({
      fuente <- input$fuente_datos
      req(!is.null(fuente) && nchar(fuente) > 0)
      if (fuente != "propio") {
        tryCatch({
          e <- new.env()
          load(system.file(paste0("app/data/", fuente, ".rda"), package = "StatML"), envir = e)
          df <- get(fuente, envir = e)
          dplyr::mutate(df, dplyr::across(where(is.character), as.factor))
        }, error = function(err) {
          showNotification(paste("Error al cargar dataset:", conditionMessage(err)),
                           type = "error", duration = 6)
          NULL
        })
      } else {
        req(input$archivo_datos)
        ext <- tools::file_ext(input$archivo_datos$name)
        tryCatch({
          df <- if (ext %in% c("xlsx", "xls"))
            readxl::read_excel(input$archivo_datos$datapath)
          else
            readr::read_delim(input$archivo_datos$datapath,
                              delim = input$separador, show_col_types = FALSE)
          dplyr::mutate(df, dplyr::across(where(is.character), as.factor))
        }, error = function(e) {
          showNotification(paste("Error al leer el archivo:", conditionMessage(e)),
                           type = "error", duration = 6)
          NULL
        })
      }
    })

    output$info_dataset <- renderUI({
      fuente <- input$fuente_datos
      if (is.null(fuente) || fuente == "propio") return(NULL)
      descripciones <- list(
        aves_densidad_paisaje  = "Densidad de aves en 600 sitios del paisaje. Relaciones no lineales con cobertura forestal, altitud y temperatura. Ideal para comparar LM vs RF.",
        aves_conteo_paisaje    = "Abundancia de aves en 800 sitios del paisaje. Fuertes no linealidades — RF debería superar claramente a LM.",
        biomasa_paisaje        = "Biomasa forestal en 600 sitios. Variables: precipitaci\u00f3n, temperatura, pH del suelo, nutrientes, altitud, perturbaci\u00f3n y cobertura del dosel.",
        pie_crab               = "Ancho del caparaz\u00f3n (mm) del cangrejo violinista en marismas costeras. Fuente: Johnson, D. (2019). doi:10.6073/pasta/4c27d2e778d3325d3830a5142e3839bb",
        sacramento             = "Precio de casas en Sacramento, California. Variables: camas, ba\u00f1os, \u00e1rea (sqft), tipo de propiedad y coordenadas geogr\u00e1ficas.",
        winequality_red        = "Calidad de vino tinto (escala 0-10) en funci\u00f3n de 11 caracter\u00edsticas fisicoqu\u00edmicas. UCI ML Repository."
      )
      desc <- descripciones[[fuente]]
      if (is.null(desc)) return(NULL)
      div(class = "alert alert-info small py-2 px-3 mb-0",
        bsicons::bs_icon("info-circle-fill", class = "me-1"), desc)
    })

    output$metricas_datos <- renderUI({
      req(datos_raw())
      df    <- datos_raw()
      n_num <- sum(sapply(df, is.numeric))
      n_cat <- sum(sapply(df, function(x) is.factor(x) || is.character(x)))
      fluidRow(
        column(4, div(
          style = "background:#fff; border:1px solid #C8D9EC; border-radius:8px; padding:1rem; text-align:center; margin-bottom:0.5rem;",
          div(style = "font-size:1.8rem; font-weight:700; color:#1170AA;", nrow(df)),
          div(style = "font-size:0.82rem; color:#57606C;", "Observaciones")
        )),
        column(4, div(
          style = "background:#fff; border:1px solid #C8D9EC; border-radius:8px; padding:1rem; text-align:center; margin-bottom:0.5rem;",
          div(style = "font-size:1.8rem; font-weight:700; color:#FC7D0B;", n_num),
          div(style = "font-size:0.82rem; color:#57606C;", "Num\u00e9ricas")
        )),
        column(4, div(
          style = "background:#fff; border:1px solid #C8D9EC; border-radius:8px; padding:1rem; text-align:center; margin-bottom:0.5rem;",
          div(style = "font-size:1.8rem; font-weight:700; color:#1170AA;", n_cat),
          div(style = "font-size:0.82rem; color:#57606C;", "Categ\u00f3ricas")
        ))
      )
    })

    output$tabla_vista_previa <- DT::renderDT({
      req(datos_raw())
      DT::datatable(datos_raw(),
        options = list(scrollX = TRUE, pageLength = 10, dom = "tip"),
        rownames = FALSE)
    })

    output$tabla_tipos <- renderUI({
      df <- datos_raw(); req(df)
      tu <- tipos_usuario()
      filas <- lapply(names(df), function(nm) {
        col    <- df[[nm]]
        actual <- if (is.factor(col) || is.character(col)) "factor" else "numeric"
        icono  <- if (actual == "factor")
          bsicons::bs_icon("tag-fill", style = paste0("color:", colores$acento))
        else
          bsicons::bs_icon("123", style = paste0("color:", colores$primario))
        sel <- if (!is.null(tu) && !is.null(tu[[nm]])) tu[[nm]] else actual
        tags$tr(
          tags$td(style = "vertical-align:middle; padding:5px 8px;",
                  div(class = "d-flex align-items-center gap-2", icono, strong(nm))),
          tags$td(style = "vertical-align:middle; padding:5px 8px;",
                  tags$span(class = "badge",
                            style = paste0("background:",
                              if (actual == "factor") colores$acento else colores$primario,
                              "; font-size:0.75rem;"),
                            if (actual == "factor") "Factor" else "Num\u00e9rico")),
          tags$td(style = "padding:5px 8px;",
                  selectInput(paste0(ns("tipo_"), nm), NULL,
                    choices  = c("Num\u00e9rico" = "numeric",
                                 "Factor (categ\u00f3rico)" = "factor",
                                 "Excluir" = "excluir"),
                    selected = sel, width = "180px")),
          tags$td(style = "vertical-align:middle; padding:5px 8px;",
                  if (!is.null(tu) && !is.null(tu[[nm]]) && tu[[nm]] != actual)
                    tags$span(class = "badge",
                              style = paste0("background:", colores$exito), "Modificado")
                  else tags$span(class = "text-muted small", "Sin cambios"))
        )
      })
      tags$table(class = "table table-sm table-hover small mb-0",
        tags$thead(
          style = paste0("background:", colores$primario, " !important; color:#fff !important;"),
          tags$tr(
            tags$th(style = "padding:7px 8px;", "Variable"),
            tags$th(style = "padding:7px 8px;", "Tipo detectado"),
            tags$th(style = "padding:7px 8px;", "Tipo a usar"),
            tags$th(style = "padding:7px 8px;", "Estado")
          )
        ),
        tags$tbody(filas)
      )
    })

    output$tipos_aplicados_msg <- renderUI({
      tu <- tipos_usuario(); if (is.null(tu)) return(NULL)
      df <- datos_raw(); req(df)
      n_cambios <- sum(sapply(names(tu), function(nm) {
        if (!nm %in% names(df)) return(FALSE)
        actual <- if (is.factor(df[[nm]]) || is.character(df[[nm]])) "factor" else "numeric"
        !is.null(tu[[nm]]) && tu[[nm]] != actual && tu[[nm]] != "excluir"
      }))
      n_excl <- sum(sapply(tu, function(t) !is.null(t) && t == "excluir"))
      if (n_cambios == 0 && n_excl == 0) return(NULL)
      div(class = "alert alert-info small py-2 px-3 mt-2 mb-0",
        bsicons::bs_icon("check-circle-fill", class = "me-1",
                style = paste0("color:", colores$exito)),
        if (n_cambios > 0) paste0(n_cambios, " variable(s) convertida(s). "),
        if (n_excl > 0) paste0(n_excl, " variable(s) excluida(s). "),
        "El modelo usar\u00e1 estos tipos.")
    })

    # PESTAÑA 4: Explorar
    # ════════════════════════════════════════════════

    output$sel_var_resp_explorar <- renderUI({
      req(datos_raw())
      vars_num <- names(datos_raw())[sapply(datos_raw(), is.numeric)]
      selectInput(ns("var_resp_explorar"), "Variable respuesta (Y)",
                  choices = vars_num, selected = vars_num[1])
    })

    output$sel_var_x_explorar <- renderUI({
      req(datos_raw())
      selectInput(ns("var_x_explorar"), "Variable X",
                  choices = names(datos_raw()), selected = names(datos_raw())[2])
    })

    output$sel_color_explorar <- renderUI({
      req(datos_raw())
      vars_cat <- c("Ninguna", names(datos_raw())[sapply(datos_raw(),
                    function(x) is.character(x) || is.factor(x))])
      selectInput(ns("color_explorar"), "Color por", choices = vars_cat)
    })

    output$plot_explorar <- plotly::renderPlotly({
      req(datos_raw(), input$var_resp_explorar, input$var_x_explorar)
      df  <- datos_raw()
      y_v <- input$var_resp_explorar
      x_v <- input$var_x_explorar
      col <- if (!is.null(input$color_explorar) && input$color_explorar != "Ninguna")
               input$color_explorar else NULL
      p <- switch(input$tipo_grafico_explorar,
        "scatter" = {
          x_is_cat <- is.factor(df[[x_v]]) || is.character(df[[x_v]])
          geom_pts <- if (x_is_cat)
            ggplot2::geom_jitter(alpha = 0.5, width = 0.2, height = 0)
          else
            ggplot2::geom_point(alpha = 0.6)
          if (!is.null(col)) {
            ggplot2::ggplot(df, ggplot2::aes(x = .data[[x_v]], y = .data[[y_v]],
                                              color = .data[[col]])) +
              geom_pts +
              ggplot2::geom_smooth(method = "loess", formula = y ~ x, se = TRUE) +
              scale_color_tableau_cb()
          } else {
            ggplot2::ggplot(df, ggplot2::aes(x = .data[[x_v]], y = .data[[y_v]])) +
              geom_pts +
              ggplot2::geom_smooth(method = "loess", formula = y ~ x, se = TRUE, color = colores$acento)
          }
        },
        "hist" = ggplot2::ggplot(df, ggplot2::aes(x = .data[[y_v]])) +
          ggplot2::geom_histogram(fill = colores$primario, color = "white", bins = 30),
        "boxplot" = ggplot2::ggplot(df, ggplot2::aes(x = .data[[x_v]], y = .data[[y_v]])) +
          ggplot2::geom_boxplot(fill = colores$secundario),
        "corr" = {
          vars_num <- names(df)[sapply(df, is.numeric)]
          cor_mat  <- cor(df[, vars_num], use = "complete.obs")
          cor_df   <- as.data.frame(as.table(cor_mat))
          names(cor_df) <- c("Var1", "Var2", "Correlacion")
          ggplot2::ggplot(cor_df, ggplot2::aes(x = Var1, y = Var2, fill = Correlacion)) +
            ggplot2::geom_tile() +
            ggplot2::scale_fill_gradient2(low = colores$peligro, high = colores$primario,
                                          mid = "white", midpoint = 0) +
            ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
        }
      )
      plotly::ggplotly(p + ggplot2::theme_minimal() + ggplot2::labs(title = NULL))
    })

    output$tabla_resumen_explorar <- DT::renderDT({
      req(datos_raw())
      df <- datos_raw()
      vars_num <- names(df)[sapply(df, is.numeric)]
      resumen <- do.call(rbind, lapply(vars_num, function(v) {
        x <- df[[v]]
        data.frame(Variable = v,
          Min    = round(min(x, na.rm = TRUE), 3),
          Media  = round(mean(x, na.rm = TRUE), 3),
          Mediana= round(median(x, na.rm = TRUE), 3),
          Max    = round(max(x, na.rm = TRUE), 3),
          SD     = round(sd(x, na.rm = TRUE), 3),
          `NA`   = sum(is.na(x)), check.names = FALSE)
      }))
      DT::datatable(resumen, options = list(pageLength = 10, dom = "tip"), rownames = FALSE)
    })

    # PESTAÑA 5: Preprocesamiento
    # ════════════════════════════════════════════════

    output$sel_var_respuesta <- renderUI({
      req(datos_raw())
      vars_num <- names(datos_raw())[sapply(datos_raw(), is.numeric)]
      selectInput(ns("var_respuesta"), "Variable respuesta (Y)",
                  choices = vars_num, selected = vars_num[1])
    })

    output$sel_predictores <- renderUI({
      req(datos_raw(), input$var_respuesta)
      vars <- setdiff(names(datos_raw()), input$var_respuesta)
      checkboxGroupInput(ns("predictores"), "Predictores (X)",
                         choices = vars, selected = vars)
    })

    datos_activos <- reactive({
      df <- datos_raw(); req(df)
      tu <- tipos_usuario()
      if (!is.null(tu)) {
        for (nm in names(tu)) {
          if (!nm %in% names(df)) next
          if (tu[[nm]] == "factor")  df[[nm]] <- as.factor(df[[nm]])
          if (tu[[nm]] == "numeric") df[[nm]] <- as.numeric(df[[nm]])
          if (tu[[nm]] == "excluir") df[[nm]] <- NULL
        }
      }
      df
    })

    datos_modelo <- reactive({
      req(datos_activos(), input$var_respuesta, input$predictores)
      df   <- datos_activos()
      cols <- intersect(c(input$var_respuesta, input$predictores), names(df))
      df[, cols]
    })

    split_datos <- reactive({
      req(datos_modelo())
      set.seed(input$semilla)
      rsample::initial_split(datos_modelo(), prop = input$prop_train)
    })

    output$resumen_preprocesamiento <- renderUI({
      req(split_datos())
      sp <- split_datos()
      tagList(
        fluidRow(
          column(6,
            div(class = "card",
              div(class = "card-header", "Entrenamiento"),
              div(class = "card-body",
                div(class = "metrica-card",
                  div(class = "metrica-valor", nrow(rsample::training(sp))),
                  div(class = "metrica-label", "observaciones"))))),
          column(6,
            div(class = "card",
              div(class = "card-header", "Prueba"),
              div(class = "card-body",
                div(class = "metrica-card",
                  div(class = "metrica-valor", nrow(rsample::testing(sp))),
                  div(class = "metrica-label", "observaciones")))))
        ),
        br(),
        div(class = "card",
          div(class = "card-header", "Receta"),
          div(class = "card-body",
            tags$ul(
              tags$li(paste("Variable respuesta:", input$var_respuesta)),
              tags$li(paste("Predictores:", length(input$predictores))),
              if (input$step_dummy) tags$li("\u2713 Variables dummy para categ\u00f3ricas"),
              if (input$step_zv)   tags$li("\u2713 Eliminaci\u00f3n de varianza cero")
            )
          )
        )
      )
    })

    # PESTAÑA 6: Ajustar modelo
    # ════════════════════════════════════════════════

    hacer_receta <- function(train) {
      rec <- recipes::recipe(
        as.formula(paste(input$var_respuesta, "~ .")),
        data = train
      )
      if (input$step_dummy) rec <- rec |> recipes::step_dummy(recipes::all_nominal_predictors())
      if (input$step_zv)    rec <- rec |> recipes::step_zv(recipes::all_predictors())
      rec
    }

    tuning_resultado <- eventReactive(input$btn_tuning, {
      req(split_datos(), input$var_respuesta, input$predictores)
      tryCatch({
        train <- rsample::training(split_datos())
        folds <- rsample::vfold_cv(train, v = input$cv_folds_tuning)
        rec   <- hacer_receta(train)

        mod <- parsnip::rand_forest(
          trees = tune::tune(),
          mtry  = tune::tune(),
          min_n = tune::tune()
        ) |>
          parsnip::set_engine("ranger") |>
          parsnip::set_mode("regression")

        wf <- workflows::workflow() |>
          workflows::add_recipe(rec) |>
          workflows::add_model(mod)

        grid <- dials::grid_latin_hypercube(
          dials::trees(range = input$trees_range),
          dials::mtry(range  = input$mtry_range),
          dials::min_n(range = input$min_n_range),
          size = input$grid_size
        )

        res <- tune::tune_grid(wf, resamples = folds, grid = grid,
          metrics = yardstick::metric_set(yardstick::rmse, yardstick::rsq))

        showNotification("Tuning completado.", type = "message", duration = 3)
        res
      }, error = function(e) {
        showNotification(paste("Error en tuning:", conditionMessage(e)),
                         type = "error", duration = 8)
        NULL
      })
    })

    output$resumen_tuning <- renderUI({
      if (is.null(tuning_resultado())) {
        return(div(class = "alert alert-info",
          bsicons::bs_icon("info-circle"), " ",
          "Ejecuta primero la b\u00fasqueda de hiperpar\u00e1metros."))
      }
      mejores <- tune::show_best(tuning_resultado(), metric = "rmse", n = 5)
      tagList(
        h5("Mejores combinaciones (por RMSE en CV)"),
        DT::renderDT(
          DT::datatable(
            mejores[, c("trees", "mtry", "min_n", "mean", "std_err")],
            colnames = c("trees", "mtry", "min_n", "RMSE medio", "SE"),
            options  = list(dom = "t", pageLength = 5),
            rownames = FALSE
          ) |> DT::formatRound(c("mean", "std_err"), digits = 4)
        )
      )
    })

    modelo_ajustado <- eventReactive(input$btn_ajustar, {
      req(split_datos(), input$var_respuesta, input$predictores)
      tryCatch({
        sp    <- split_datos()
        train <- rsample::training(sp)
        rec   <- hacer_receta(train)

        # Usar mejores hiperparámetros si hay tuning, sino defaults
        if (!is.null(tuning_resultado())) {
          mejores <- tune::select_best(tuning_resultado(), metric = "rmse")
          mod <- parsnip::rand_forest(
            trees = mejores$trees,
            mtry  = mejores$mtry,
            min_n = mejores$min_n
          ) |>
            parsnip::set_engine("ranger", importance = "permutation") |>
            parsnip::set_mode("regression")
        } else {
          mod <- parsnip::rand_forest() |>
            parsnip::set_engine("ranger", importance = "permutation") |>
            parsnip::set_mode("regression")
        }

        wf <- workflows::workflow() |>
          workflows::add_recipe(rec) |>
          workflows::add_model(mod)

        resultado <- tune::last_fit(wf, sp)
        showNotification("Modelo ajustado correctamente.", type = "message", duration = 3)
        resultado
      }, error = function(e) {
        showNotification(paste("Error al ajustar:", conditionMessage(e)),
                         type = "error", duration = 8)
        NULL
      })
    })

    output$estado_modelo <- renderUI({
      if (is.null(modelo_ajustado())) return(NULL)
      div(class = "alert alert-success mt-2",
        bsicons::bs_icon("check-circle"), " Modelo ajustado correctamente")
    })

    output$resumen_modelo <- renderUI({
      req(modelo_ajustado())
      m <- tune::collect_metrics(modelo_ajustado())
      tagList(
        h5("Métricas en datos de prueba"),
        fluidRow(
          column(4, div(class = "metrica-card",
            div(class = "metrica-valor",
                round(m$.estimate[m$.metric == "rmse"], 3)),
            div(class = "metrica-label", "RMSE (test)"))),
          column(4, div(class = "metrica-card",
            div(class = "metrica-valor",
                round(m$.estimate[m$.metric == "rsq"], 3)),
            div(class = "metrica-label", "R² (test)"))),
          column(4, div(class = "metrica-card",
            div(class = "metrica-valor", length(input$predictores)),
            div(class = "metrica-label", "Predictores")))
        )
      )
    })

    # PESTAÑA 7: Diagnóstico
    # ════════════════════════════════════════════════

    ajuste_train <- reactive({
      req(modelo_ajustado())
      wf_fit <- tune::extract_workflow(modelo_ajustado())
      train  <- rsample::training(split_datos())
      preds  <- predict(wf_fit, train)$.pred
      resids <- train[[input$var_respuesta]] - preds
      list(fitted = preds, residuals = resids, y = train[[input$var_respuesta]])
    })

    output$plot_resid_fitted <- plotly::renderPlotly({
      req(ajuste_train())
      at <- ajuste_train()
      df <- data.frame(fitted = at$fitted, residuals = at$residuals)
      p  <- ggplot2::ggplot(df, ggplot2::aes(x = fitted, y = residuals)) +
        ggplot2::geom_point(alpha = 0.4, color = colores$primario) +
        ggplot2::geom_hline(yintercept = 0, color = colores$acento, linetype = "dashed") +
        ggplot2::geom_smooth(method = "loess", formula = y ~ x, se = FALSE, color = colores$peligro, linewidth = 0.8) +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = "Valores ajustados", y = "Residuos")
      plotly::ggplotly(p)
    })

    output$plot_resid_hist <- plotly::renderPlotly({
      req(ajuste_train())
      df <- data.frame(residuals = ajuste_train()$residuals)
      p  <- ggplot2::ggplot(df, ggplot2::aes(x = residuals)) +
        ggplot2::geom_histogram(fill = colores$primario, color = "white", bins = 30) +
        ggplot2::geom_vline(xintercept = 0, color = colores$acento, linetype = "dashed") +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = "Residuos", y = "Frecuencia")
      plotly::ggplotly(p)
    })

    output$plot_resid_index <- plotly::renderPlotly({
      req(ajuste_train())
      at <- ajuste_train()
      df <- data.frame(index = seq_along(at$residuals), residuals = at$residuals)
      p  <- ggplot2::ggplot(df, ggplot2::aes(x = index, y = residuals)) +
        ggplot2::geom_point(alpha = 0.4, color = colores$primario) +
        ggplot2::geom_hline(yintercept = 0, color = colores$acento, linetype = "dashed") +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = "\u00cdndice", y = "Residuos")
      plotly::ggplotly(p)
    })

    output$plot_oob <- plotly::renderPlotly({
      req(modelo_ajustado())
      tryCatch({
        rf_fit <- tune::extract_fit_engine(modelo_ajustado()$.workflow[[1]])
        if (!is.null(rf_fit$prediction.error)) {
          oob_df <- data.frame(
            trees = seq_along(rf_fit$forest$child.nodeIDs),
            oob   = rf_fit$prediction.error
          )
          p <- ggplot2::ggplot(data.frame(oob = rf_fit$prediction.error),
                               ggplot2::aes(x = 1, y = oob)) +
            ggplot2::geom_col(fill = colores$primario) +
            ggplot2::theme_minimal() +
            ggplot2::labs(x = NULL, y = "OOB Error (MSE)", title = "Error Out-of-Bag")
          plotly::ggplotly(p)
        } else {
          plotly::plot_ly() |>
            plotly::add_annotations(text = "OOB no disponible", showarrow = FALSE)
        }
      }, error = function(e) {
        plotly::plot_ly() |>
          plotly::add_annotations(text = "OOB no disponible", showarrow = FALSE)
      })
    })

    # PESTAÑA 8: Performance
    # ════════════════════════════════════════════════

    metrica_card_grande <- function(valor, label, sublabel, color) {
      div(class = "card mb-3",
        div(class = "card-body text-center",
          div(style = paste0("font-size:0.85rem; font-weight:600; color:", color,
                             "; text-transform:uppercase; letter-spacing:0.05em; margin-bottom:0.3rem;"),
              label),
          div(style = paste0("font-size:2.4rem; font-weight:800; color:", color, "; line-height:1;"),
              valor),
          div(style = "font-size:0.78rem; color:#57606C; margin-top:0.3rem;", sublabel)
        )
      )
    }

    output$card_rmse_train <- renderUI({
      req(ajuste_train())
      at   <- ajuste_train()
      rmse <- round(sqrt(mean((at$y - at$fitted)^2)), 3)
      metrica_card_grande(rmse, "RMSE \u2014 Entrenamiento",
        "Error cuadr\u00e1tico medio en train (optimista)", "#1170AA")
    })

    output$card_rmse_test <- renderUI({
      req(modelo_ajustado())
      m <- tune::collect_metrics(modelo_ajustado())
      metrica_card_grande(round(m$.estimate[m$.metric == "rmse"], 3),
        "RMSE \u2014 Prueba", "Error cuadr\u00e1tico medio en test (real)", "#C85200")
    })

    output$card_rsq_train <- renderUI({
      req(ajuste_train())
      at  <- ajuste_train()
      rsq <- round(1 - sum((at$y - at$fitted)^2) / sum((at$y - mean(at$y))^2), 3)
      metrica_card_grande(rsq, "R\u00b2 \u2014 Entrenamiento",
        "Varianza explicada en train (optimista)", "#1170AA")
    })

    output$card_rsq_test <- renderUI({
      req(modelo_ajustado())
      m <- tune::collect_metrics(modelo_ajustado())
      metrica_card_grande(round(m$.estimate[m$.metric == "rsq"], 3),
        "R\u00b2 \u2014 Prueba", "Varianza explicada en test (real)", "#C85200")
    })

    output$semaforo_performance <- renderUI({
      req(modelo_ajustado())
      m      <- tune::collect_metrics(modelo_ajustado())
      rsq_v  <- m$.estimate[m$.metric == "rsq"]
      rmse_v <- m$.estimate[m$.metric == "rmse"]
      clase  <- if (rsq_v >= 0.7) "sem-ok" else if (rsq_v >= 0.4) "sem-warn" else "sem-bad"
      icono  <- if (rsq_v >= 0.7) bsicons::bs_icon("check-circle-fill")
                else if (rsq_v >= 0.4) bsicons::bs_icon("exclamation-triangle-fill")
                else bsicons::bs_icon("x-circle-fill")
      msg    <- if (rsq_v >= 0.7) "Buen ajuste predictivo"
                else if (rsq_v >= 0.4) "Ajuste moderado"
                else "Ajuste d\u00e9bil"
      div(class = paste("card p-3", clase),
        div(class = "d-flex align-items-center gap-2 mb-2", icono,
            h5(class = "mb-0", "Evaluaci\u00f3n")),
        p(class = "mb-1", strong(msg)),
        p(class = "small text-muted mb-0",
          "R\u00b2 (test): ", strong(round(rsq_v, 3)),
          " | RMSE (test): ", strong(round(rmse_v, 3)))
      )
    })

    output$tabla_tuning_performance <- renderUI({
      if (is.null(tuning_resultado())) {
        return(div(class = "alert alert-info",
          bsicons::bs_icon("info-circle"), " ",
          "Ejecuta el tuning en la pesta\u00f1a 'Ajustar modelo' para ver los resultados."))
      }
      m <- tune::collect_metrics(tuning_resultado()) |>
        dplyr::filter(.metric == "rmse") |>
        dplyr::arrange(mean) |>
        head(10)
      DT::renderDT(
        DT::datatable(
          m[, c("trees", "mtry", "min_n", "mean", "std_err")],
          colnames = c("trees", "mtry", "min_n", "RMSE medio CV", "SE"),
          options  = list(dom = "tip", pageLength = 10),
          rownames = FALSE
        ) |> DT::formatRound(c("mean", "std_err"), digits = 4)
      )
    })

    # PESTAÑA 9: Predicciones
    # ════════════════════════════════════════════════

    preds_test <- reactive({
      req(modelo_ajustado())
      tune::collect_predictions(modelo_ajustado())
    })

    output$plot_obs_pred <- plotly::renderPlotly({
      req(preds_test(), input$var_respuesta)
      df      <- preds_test()
      obs_col <- input$var_respuesta
      if (!obs_col %in% names(df))
        obs_col <- names(df)[!names(df) %in% c(".pred", ".row", ".config", "id")][1]
      lim <- range(c(df[[obs_col]], df$.pred), na.rm = TRUE)
      p <- ggplot2::ggplot(df, ggplot2::aes(x = .data[[obs_col]], y = .pred)) +
        ggplot2::geom_point(alpha = 0.5, color = colores$primario) +
        ggplot2::geom_abline(slope = 1, intercept = 0,
                              color = colores$acento, linetype = "dashed") +
        ggplot2::coord_equal(xlim = lim, ylim = lim) +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = "Observado", y = "Predicho")
      plotly::ggplotly(p)
    })

    output$plot_resid_dist <- plotly::renderPlotly({
      req(preds_test(), input$var_respuesta)
      df      <- preds_test()
      obs_col <- input$var_respuesta
      if (!obs_col %in% names(df))
        obs_col <- names(df)[!names(df) %in% c(".pred", ".row", ".config", "id")][1]
      df$resid <- df[[obs_col]] - df$.pred
      p <- ggplot2::ggplot(df, ggplot2::aes(x = resid)) +
        ggplot2::geom_histogram(fill = colores$primario, color = "white", bins = 25) +
        ggplot2::geom_vline(xintercept = 0, color = colores$acento, linetype = "dashed") +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = "Residuo (obs - pred)", y = "Frecuencia")
      plotly::ggplotly(p)
    })

    output$tabla_predicciones <- DT::renderDT({
      req(preds_test(), input$var_respuesta)
      df      <- preds_test()
      obs_col <- input$var_respuesta
      if (!obs_col %in% names(df))
        obs_col <- names(df)[!names(df) %in% c(".pred", ".row", ".config", "id")][1]
      df$Predicho <- round(df$.pred, 3)
      df$Residuo  <- round(df[[obs_col]] - df$.pred, 3)
      out <- df[, c(obs_col, "Predicho", "Residuo")]
      names(out)[1] <- "Observado"
      DT::datatable(out, options = list(pageLength = 10, scrollX = TRUE, dom = "tip"),
                    rownames = FALSE)
    })

    # PESTAÑA 10: Importancia
    # ════════════════════════════════════════════════

    importancia <- reactive({
      req(modelo_ajustado(), input$var_respuesta)
      tryCatch({
        wf_fit <- tune::extract_workflow(modelo_ajustado())
        train  <- rsample::training(split_datos())
        vip::vi(wf_fit,
                method       = "permute",
                target       = input$var_respuesta,
                metric       = "rmse",
                pred_wrapper = function(object, newdata) predict(object, newdata)$.pred,
                train        = train,
                nsim         = 10)
      }, error = function(e) {
        showNotification(paste("Error en importancia:", conditionMessage(e)),
                         type = "error", duration = 6)
        NULL
      })
    })

    output$plot_importancia <- plotly::renderPlotly({
      req(importancia())
      imp <- importancia()
      imp <- imp[order(imp$Importance, decreasing = FALSE), ]
      imp$Variable <- factor(imp$Variable, levels = imp$Variable)
      p <- ggplot2::ggplot(imp, ggplot2::aes(x = Importance, y = Variable)) +
        ggplot2::geom_col(fill = colores$primario) +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = "Aumento en RMSE (permutaci\u00f3n)", y = NULL,
                      title = "Importancia por permutaci\u00f3n")
      plotly::ggplotly(p)
    })

    output$tabla_importancia <- DT::renderDT({
      req(importancia())
      imp <- importancia()
      imp$Importance <- round(imp$Importance, 4)
      DT::datatable(imp,
        colnames = c("Variable", "Importancia (aumento RMSE)"),
        options  = list(pageLength = 10, dom = "tip"),
        rownames = FALSE)
    })

    # PESTAÑA 11: PDP
    # ════════════════════════════════════════════════

    output$sel_var_pdp <- renderUI({
      req(modelo_ajustado())
      selectInput(ns("var_pdp"), "Variable para PDP",
                  choices = input$predictores, selected = input$predictores[1])
    })

    output$plot_pdp <- plotly::renderPlotly({
      req(modelo_ajustado(), input$var_pdp)
      wf_fit <- tune::extract_workflow(modelo_ajustado())
      train  <- rsample::training(split_datos())
      var    <- input$var_pdp
      n_grid <- input$grid_pdp

      grid_vals <- if (is.numeric(train[[var]]))
        seq(min(train[[var]], na.rm = TRUE), max(train[[var]], na.rm = TRUE), length.out = n_grid)
      else unique(train[[var]])

      pdp_df <- do.call(rbind, lapply(grid_vals, function(v) {
        df_tmp <- train
        df_tmp[[var]] <- v
        data.frame(x = v, y_hat = mean(predict(wf_fit, df_tmp)$.pred, na.rm = TRUE))
      }))

      p <- ggplot2::ggplot(pdp_df, ggplot2::aes(x = x, y = y_hat)) +
        ggplot2::geom_line(color = colores$primario, linewidth = 1.2) +
        ggplot2::geom_point(color = colores$acento, size = 2) +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = var,
                      y = paste("Predicci\u00f3n promedio de", input$var_respuesta),
                      title = paste("PDP \u2014", var))
      plotly::ggplotly(p)
    })

    # PESTAÑA 12: Código R
    # ════════════════════════════════════════════════

    codigo_r <- reactive({
      req(input$var_respuesta, input$predictores)
      paste0(
        encabezado_script("StatML", "Random Forest Regresi\u00f3n"),
        "library(tidymodels)\nlibrary(ranger)\n\n",
        "# Cargar datos\n# datos <- read_excel('tus_datos.xlsx')\n\n",
        "# División train/test\nset.seed(", input$semilla, ")\n",
        "split <- initial_split(datos, prop = ", input$prop_train, ")\n",
        "train <- training(split)\ntest  <- testing(split)\n\n",
        "# Receta\nreceta <- recipe(", input$var_respuesta, " ~ ",
        paste(input$predictores, collapse = " + "), ", data = train)",
        if (input$step_dummy) " |>\n  step_dummy(all_nominal_predictors())" else "",
        if (input$step_zv)    " |>\n  step_zv(all_predictors())" else "",
        "\n\n# Modelo con tuning\nmodelo <- rand_forest(\n",
        "  trees = tune(), mtry = tune(), min_n = tune()\n) |>\n",
        "  set_engine('ranger', importance = 'permutation') |>\n",
        "  set_mode('regression')\n\n",
        "# Workflow\nwf <- workflow() |>\n",
        "  add_recipe(receta) |>\n  add_model(modelo)\n\n",
        "# Grid search\nfolds <- vfold_cv(train, v = ", input$cv_folds_tuning, ")\n",
        "grid  <- grid_latin_hypercube(\n",
        "  trees(range = c(", input$trees_range[1], ", ", input$trees_range[2], ")),\n",
        "  mtry(range  = c(", input$mtry_range[1],  ", ", input$mtry_range[2],  ")),\n",
        "  min_n(range = c(", input$min_n_range[1],  ", ", input$min_n_range[2],  ")),\n",
        "  size = ", input$grid_size, "\n)\n\n",
        "res     <- tune_grid(wf, resamples = folds, grid = grid)\n",
        "mejores <- select_best(res, metric = 'rmse')\n",
        "wf_fin  <- finalize_workflow(wf, mejores)\n\n",
        "# Ajuste final\najuste   <- last_fit(wf_fin, split)\n",
        "metricas <- collect_metrics(ajuste)\n",
        "preds    <- collect_predictions(ajuste)\n\n",
        "# Importancia\nlibrary(vip)\n",
        "vi(extract_workflow(ajuste), method = 'permute',\n",
        "   target = '", input$var_respuesta, "', metric = 'rmse',\n",
        "   pred_wrapper = function(o, nd) predict(o, nd)$.pred,\n",
        "   train = train)\n"
      )
    })

    output$codigo_reproducible <- renderText({ req(codigo_r()); codigo_r() })

    output$btn_descargar_codigo <- downloadHandler(
      filename = function() paste0("StatML_rf_reg_", Sys.Date(), ".R"),
      content  = function(file) writeLines(codigo_r(), file)
    )

  }) # /moduleServer
} # /mod_rf_reg_server
