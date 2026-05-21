# ============================================================
# mod_lm_ml.R — Regresión lineal (enfoque predictivo)
# StatML · StatSuite
# Manuel Spínola · ICOMVIS · UNA · Costa Rica
# ============================================================

# ── UI ──────────────────────────────────────────────────────
#' @noRd
mod_lm_ml_ui <- function(id) {
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
              h4(tagList(bsicons::bs_icon("graph-up", class = "me-2"), "Regresión lineal en Machine Learning")),
              p(class = "lead",
                "La regresión lineal es el punto de partida del aprendizaje automático supervisado.
                 A diferencia del enfoque inferencial, aquí el objetivo es ", strong("predecir"),
                " nuevos valores con la mayor precisión posible."),
              hr(),
              h5("¿En qué se diferencia del enfoque inferencial?"),
              fluidRow(
                column(6,
                  div(class = "card mb-3",
                    div(class = "card-header", tagList(bsicons::bs_icon("search"), " Enfoque inferencial (StatModels)")),
                    div(class = "card-body",
                      tags$ul(
                        tags$li("¿Qué variables son significativas?"),
                        tags$li("¿Cuál es el efecto de X sobre Y?"),
                        tags$li("¿Se cumplen los supuestos?"),
                        tags$li("p-valores, intervalos de confianza")
                      )
                    )
                  )
                ),
                column(6,
                  div(class = "card mb-3",
                    div(class = "card-header", tagList(bsicons::bs_icon("robot"), " Enfoque predictivo (StatML)")),
                    div(class = "card-body",
                      tags$ul(
                        tags$li("¿Qué tan bien predice el modelo?"),
                        tags$li("¿Generaliza a datos nuevos?"),
                        tags$li("RMSE, R², MAE en datos de prueba"),
                        tags$li("Train/test split, validación cruzada")
                      )
                    )
                  )
                )
              ),
              h5("Fórmula del modelo"),
              div(class = "codigo-bloque",
                "Y = β₀ + β₁X₁ + β₂X₂ + ... + βₙXₙ + ε"
              ),
              br(),
              p("Donde ", strong("Y"), " es la variable respuesta continua, ",
                strong("X₁...Xₙ"), " son los predictores, y ",
                strong("ε"), " es el error aleatorio.")
            ),
            column(4,
              div(class = "card",
                div(class = "card-header", tagList(bsicons::bs_icon("list-check"), " En este módulo aprenderás")),
                div(class = "card-body",
                  tags$ol(
                    tags$li("Cargar y explorar tus datos"),
                    tags$li("Preprocesar variables"),
                    tags$li("Dividir datos en entrenamiento y prueba"),
                    tags$li("Ajustar un modelo lineal"),
                    tags$li("Evaluar el rendimiento predictivo"),
                    tags$li("Interpretar predicciones e importancia"),
                    tags$li("Comparar con otros modelos")
                  )
                )
              ),
              br(),
              div(class = "card",
                div(class = "card-header", tagList(bsicons::bs_icon("exclamation-triangle"), " Limitaciones")),
                div(class = "card-body",
                  tags$ul(
                    tags$li("Asume relaciones lineales"),
                    tags$li("Sensible a outliers"),
                    tags$li("No captura interacciones complejas"),
                    tags$li("Puede ser superado por RF en datos no lineales")
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
          fluidRow(
            column(8,
              h4("Fundamentos de la regresión lineal predictiva"),
              bslib::navset_pill(
                bslib::nav_panel("Train/Test split",
                  br(),
                  p("El principio fundamental del ML predictivo es evaluar el modelo
                    en datos que", strong("nunca vio durante el entrenamiento.")),
                  br(),
                  # Esquema visual train/test
                  div(style = "max-width: 600px;",
                    div(style = "display: flex; height: 60px; border-radius: 8px; overflow: hidden; border: 1px solid #C8D9EC;",
                      div(style = "background: #1170AA; width: 80%; display: flex; align-items: center; justify-content: center;",
                        span(style = "color: #ffffff; font-weight: 700; font-size: 1rem;",
                             "Entrenamiento (80%)")
                      ),
                      div(style = "background: #FC7D0B; width: 20%; display: flex; align-items: center; justify-content: center;",
                        span(style = "color: #ffffff; font-weight: 700; font-size: 1rem;",
                             "Prueba (20%)")
                      )
                    ),
                    br(),
                    fluidRow(
                      column(6,
                        div(style = "border-left: 4px solid #1170AA; padding-left: 0.8rem;",
                          p(class = "mb-1", strong(style = "color:#1170AA;", "Entrenamiento")),
                          p(class = "small text-muted mb-0",
                            "El modelo aprende los patrones de estos datos.
                             Nunca se evalúa aquí.")
                        )
                      ),
                      column(6,
                        div(style = "border-left: 4px solid #FC7D0B; padding-left: 0.8rem;",
                          p(class = "mb-1", strong(style = "color:#FC7D0B;", "Prueba")),
                          p(class = "small text-muted mb-0",
                            "El modelo nunca vio estos datos. Aquí se mide
                             el rendimiento real — RMSE, R², MAE.")
                        )
                      )
                    )
                  ),
                  br(),
                  p("Si evaluamos en los mismos datos de entrenamiento, el modelo
                    siempre parecerá bueno — incluso si no generaliza. Esto se llama ",
                    strong("sobreajuste (overfitting)."))
                ),
                bslib::nav_panel("Métricas",
                  br(),
                  fluidRow(
                    column(4,
                      div(class = "metrica-card",
                        div(class = "metrica-label", "RMSE"),
                        div(class = "metrica-valor", "√MSE"),
                        p(class = "small mt-2",
                          "Error cuadrático medio. En las mismas unidades que Y.
                           Penaliza errores grandes.")
                      )
                    ),
                    column(4,
                      div(class = "metrica-card",
                        div(class = "metrica-label", "R²"),
                        div(class = "metrica-valor", "0–1"),
                        p(class = "small mt-2",
                          "Proporción de varianza explicada. 1 = perfecto.
                           Interpretación: % de variación explicada.")
                      )
                    ),
                    column(4,
                      div(class = "metrica-card",
                        div(class = "metrica-label", "MAE"),
                        div(class = "metrica-valor", "mean|e|"),
                        p(class = "small mt-2",
                          "Error absoluto medio. Más robusto a outliers que RMSE.
                           Mismo signo que Y.")
                      )
                    )
                  )
                ),

              )
            ),
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
                        "Densidad de aves (paisaje)"   = "aves_densidad_paisaje",
                        "Abundancia de aves (paisaje)"  = "aves_conteo_paisaje",
                        "Biomasa forestal"             = "biomasa_paisaje",
                        "Talla de cangrejo violinista"         = "pie_crab",
                        "Sacramento (precios de casas)"       = "sacramento",
                        "Calidad de vino tinto"        = "winequality_red",
                        "Cargar mis propios datos"     = "propio"
                      ),
                      selected = "aves_densidad_paisaje"
                    ),
                    tags$hr(),
                    fileInput(ns("archivo_datos"),
                      label       = "Seleccionar archivo:",
                      accept      = c(".csv", ".xlsx", ".xls"),
                      buttonLabel = "Buscar…",
                      placeholder = "CSV o Excel"
                    ),
                    selectInput(ns("separador"),
                      label    = "Separador (CSV):",
                      choices  = c("Coma (,)" = ",", "Punto y coma (;)" = ";", "Tabulador" = "\t"),
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
                "Las variables ", strong("categóricas"),
                " deben ser ", strong("Factor"), ". ",
                "Las variables codificadas como números pero que ",
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
                    choices = c("Dispersión"    = "scatter",
                                "Histograma"    = "hist",
                                "Boxplot"       = "boxplot",
                                "Correlación"   = "corr")
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
                    label = "Semilla (reproducibilidad)",
                    value = 123, min = 1, step = 1
                  )
                )
              ),
              div(class = "card",
                div(class = "card-header", "Pasos de la receta"),
                div(class = "card-body",
                  checkboxInput(ns("step_normalize"),
                    "Normalizar predictores numéricos", value = TRUE),
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
                div(class = "card-header", "Especificación del modelo"),
                div(class = "card-body",
                  p(class = "small text-muted",
                    "Regresión lineal con mínimos cuadrados ordinarios (OLS).",
                    br(),
                    "Motor: ", strong("lm"), " (stats)")
                )
              ),
              div(class = "card",
                div(class = "card-header", "Acciones"),
                div(class = "card-body",
                  actionButton(ns("btn_ajustar"),
                    label = tagList(bsicons::bs_icon("play-fill"), " Ajustar modelo"),
                    class = "btn-primary w-100 mb-2"
                  ),
                  uiOutput(ns("estado_modelo"))
                )
              )
            ),
            column(8,
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
            "Verificación de los supuestos del modelo lineal en los datos de entrenamiento."),
          fluidRow(
            column(6,
              h6("Residuos vs Valores ajustados"),
              plotly::plotlyOutput(ns("plot_resid_fitted"), height = "300px")
            ),
            column(6,
              h6("Q-Q Normal de residuos"),
              plotly::plotlyOutput(ns("plot_qq"), height = "300px")
            )
          ),
          br(),
          fluidRow(
            column(6,
              h6("Scale-Location"),
              plotly::plotlyOutput(ns("plot_scale_loc"), height = "300px")
            ),
            column(6,
              h6("Residuos vs Leverage"),
              plotly::plotlyOutput(ns("plot_leverage"), height = "300px")
            )
          ),
          br(),
          uiOutput(ns("resumen_diagnostico"))
        )
      ), # /PESTAÑA 7

      # PESTAÑA 8: Performance
      # ════════════════════════════════════════════════
      bslib::nav_panel(
        title = "Performance",
        icon  = bsicons::bs_icon("speedometer2"),
        div(class = "p-3",

          # ── Hold-out ──────────────────────────────
          div(style = "border-left: 4px solid #1170AA; padding-left: 1rem; margin-bottom: 1.5rem;",
            h4(style = "color: #1170AA; font-weight: 700; margin-bottom: 0.2rem;",
               bsicons::bs_icon("diagram-2", class = "me-2"), "Hold-out (Train / Test)"),
            p(class = "small text-muted mb-3",
              "El modelo se entrena con el ", strong("conjunto de entrenamiento"),
              " y se evalúa con el ", strong("conjunto de prueba"),
              " (datos que el modelo nunca vio durante el ajuste).")
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

          # ── Cross-validation ──────────────────────
          div(style = "border-left: 4px solid #FC7D0B; padding-left: 1rem; margin-bottom: 1.5rem;",
            h4(style = "color: #FC7D0B; font-weight: 700; margin-bottom: 0.2rem;",
               bsicons::bs_icon("arrow-repeat", class = "me-2"), "Validación cruzada (CV)"),
            p(class = "small text-muted mb-3",
              "Estimación más robusta del rendimiento. El conjunto de entrenamiento se divide en ",
              strong("k folds"), "; el modelo se ajusta k veces, cada vez usando un fold diferente como validación.")
          ),
          fluidRow(
            column(4,
              div(class = "card",
                div(class = "card-header", "Configuración"),
                div(class = "card-body",
                  sliderInput(ns("cv_folds"), "Número de folds (k)",
                              min = 3, max = 10, value = 5, step = 1),
                  actionButton(ns("btn_cv"), "Ejecutar CV",
                               class = "btn-primary w-100 mt-2",
                               icon = shiny::icon("play"))
                )
              )
            ),
            column(8,
              uiOutput(ns("resultados_cv"))
            )
          )
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
                "Importancia por permutación: se permuta cada variable aleatoriamente y se mide el aumento en RMSE. Método agnóstico — comparable entre LM, GLM y Random Forest."),
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
            "Los Partial Dependence Plots (PDP) muestran el efecto marginal de cada predictor
             sobre la variable respuesta, promediando sobre los demás predictores."),
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
          fluidRow(
            column(12,
              div(class = "codigo-bloque",
                verbatimTextOutput(ns("codigo_reproducible"))
              ),
              br(),
              downloadButton(ns("btn_descargar_codigo"),
                label = tagList(bsicons::bs_icon("download"), " Descargar script .R"),
                class = "btn-outline-primary"
              )
            )
          )
        )
      ) # /PESTAÑA 12

    ) # /navset_card_tab
  ) # /tagList
} # /mod_lm_ml_ui

# ── SERVER ───────────────────────────────────────────────────
#' @noRd
mod_lm_ml_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # PESTAÑA 3: Los datos
    # ════════════════════════════════════════════════

    # Tipos de variables reactivos
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
        aves_densidad_paisaje  = "Densidad de aves en 600 sitios del paisaje. Variables de cobertura forestal, altitud, temperatura, precipitación y tipo de hábitat. Datos simulados con relaciones no lineales.",
        aves_conteo_paisaje    = "Abundancia de aves en 800 sitios del paisaje. Relaciones no lineales fuertes con cobertura forestal y altitud. Datos simulados.",
        biomasa_paisaje        = "Biomasa forestal en 600 sitios. Variables: precipitación, temperatura, pH del suelo, nutrientes, altitud, perturbación y cobertura del dosel.",
        pie_crab               = "Ancho del caparazón (mm) del cangrejo violinista en marismas costeras de Florida a Massachusetts, EE.UU. (verano 2016). Variable respuesta: ancho del caparazón. Predictores: latitud, sitio, temperatura media anual del aire y del agua. Fuente: Johnson, D. (2019). doi:10.6073/pasta/4c27d2e778d3325d3830a5142e3839bb",
        sacramento             = "Precio de casas en Sacramento, California. Variables: camas, baños, área (sqft), tipo de propiedad y coordenadas geográficas.",
        winequality_red        = "Calidad de vino tinto (escala 0-10) en función de 11 características fisicoquímicas. Dataset clásico de UCI ML Repository."
      )
      desc <- descripciones[[fuente]]
      if (is.null(desc)) return(NULL)
      div(class = "alert alert-info small py-2 px-3 mb-0",
        bsicons::bs_icon("info-circle-fill", class = "me-1"),
        desc
      )
    })

    output$metricas_datos <- renderUI({
      req(datos_raw())
      df <- datos_raw()
      n_num <- sum(sapply(df, is.numeric))
      n_cat <- sum(sapply(df, function(x) is.factor(x) || is.character(x)))
      fluidRow(
        column(4, div(
          style = "background:#ffffff; border:1px solid #C8D9EC; border-radius:8px; padding:1rem; text-align:center; margin-bottom:0.5rem;",
          div(style = "font-size:1.8rem; font-weight:700; color:#1170AA;", nrow(df)),
          div(style = "font-size:0.82rem; color:#57606C;", "Observaciones")
        )),
        column(4, div(
          style = "background:#ffffff; border:1px solid #C8D9EC; border-radius:8px; padding:1rem; text-align:center; margin-bottom:0.5rem;",
          div(style = "font-size:1.8rem; font-weight:700; color:#FC7D0B;", n_num),
          div(style = "font-size:0.82rem; color:#57606C;", "Numéricas")
        )),
        column(4, div(
          style = "background:#ffffff; border:1px solid #C8D9EC; border-radius:8px; padding:1rem; text-align:center; margin-bottom:0.5rem;",
          div(style = "font-size:1.8rem; font-weight:700; color:#1170AA;", n_cat),
          div(style = "font-size:0.82rem; color:#57606C;", "Categóricas")
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
                              if (actual == "factor") colores$acento
                              else colores$primario, "; font-size:0.75rem;"),
                            if (actual == "factor") "Factor" else "Numérico")),
          tags$td(style = "padding:5px 8px;",
                  selectInput(
                    inputId  = paste0(ns("tipo_"), nm),
                    label    = NULL,
                    choices  = c("Numérico" = "numeric",
                                 "Factor (categórico)" = "factor",
                                 "Excluir" = "excluir"),
                    selected = sel, width = "180px")),
          tags$td(style = "vertical-align:middle; padding:5px 8px;",
                  if (!is.null(tu) && !is.null(tu[[nm]]) && tu[[nm]] != actual)
                    tags$span(class = "badge",
                              style = paste0("background:", colores$exito),
                              "Modificado")
                  else
                    tags$span(class = "text-muted small", "Sin cambios"))
        )
      })
      tags$table(
        class = "table table-sm table-hover small mb-0",
        tags$thead(
          style = paste0("background:", colores$primario,
                         " !important; color:#fff !important;"),
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
          "El modelo usará estos tipos.")
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
      vars <- names(datos_raw())
      selectInput(ns("var_x_explorar"), "Variable X",
                  choices = vars, selected = vars[2])
    })

    output$sel_color_explorar <- renderUI({
      req(datos_raw())
      vars_cat <- c("Ninguna", names(datos_raw())[sapply(datos_raw(), function(x) is.character(x) || is.factor(x))])
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
              ggplot2::geom_smooth(method = "lm", formula = y ~ x, se = TRUE) +
              scale_color_tableau_cb()
          } else {
            ggplot2::ggplot(df, ggplot2::aes(x = .data[[x_v]], y = .data[[y_v]])) +
              geom_pts +
              ggplot2::geom_smooth(method = "lm", formula = y ~ x, se = TRUE, color = colores$acento)
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
      plotly::ggplotly(p + ggplot2::theme_minimal() +
        ggplot2::labs(title = NULL))
    })

    output$tabla_resumen_explorar <- DT::renderDT({
      req(datos_raw())
      df <- datos_raw()
      vars_num <- names(df)[sapply(df, is.numeric)]
      resumen <- do.call(rbind, lapply(vars_num, function(v) {
        x <- df[[v]]
        data.frame(
          Variable = v,
          Min      = round(min(x, na.rm = TRUE), 3),
          Media    = round(mean(x, na.rm = TRUE), 3),
          Mediana  = round(median(x, na.rm = TRUE), 3),
          Max      = round(max(x, na.rm = TRUE), 3),
          SD       = round(sd(x, na.rm = TRUE), 3),
          `NA`     = sum(is.na(x)),
          check.names = FALSE
        )
      }))
      DT::datatable(resumen, options = list(pageLength = 10, dom = "tip"),
                    rownames = FALSE)
    })

    # PESTAÑA 5: Preprocesamiento
    # ════════════════════════════════════════════════

    output$sel_var_respuesta <- renderUI({
      req(datos_raw())
      df <- datos_raw()
      vars_num <- names(df)[sapply(df, is.numeric)]
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
      df <- datos_raw()
      req(df)
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
      df <- datos_activos()
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
                  div(class = "metrica-label", "observaciones")
                )
              )
            )
          ),
          column(6,
            div(class = "card",
              div(class = "card-header", "Prueba"),
              div(class = "card-body",
                div(class = "metrica-card",
                  div(class = "metrica-valor", nrow(rsample::testing(sp))),
                  div(class = "metrica-label", "observaciones")
                )
              )
            )
          )
        ),
        br(),
        div(class = "card",
          div(class = "card-header", "Receta de preprocesamiento"),
          div(class = "card-body",
            tags$ul(
              tags$li(paste("Variable respuesta:", input$var_respuesta)),
              tags$li(paste("Predictores:", length(input$predictores))),
              if (input$step_normalize) tags$li("✓ Normalización de predictores numéricos"),
              if (input$step_dummy)     tags$li("✓ Variables dummy para categóricas"),
              if (input$step_zv)        tags$li("✓ Eliminación de varianza cero")
            )
          )
        )
      )
    })

    # PESTAÑA 6: Ajustar modelo
    # ════════════════════════════════════════════════

    modelo_ajustado <- eventReactive(input$btn_ajustar, {
      req(split_datos(), input$var_respuesta, input$predictores)

      tryCatch({
        sp    <- split_datos()
        train <- rsample::training(sp)

        # Receta
        rec <- recipes::recipe(
          as.formula(paste(input$var_respuesta, "~ .")),
          data = train
        )
        if (input$step_normalize) rec <- rec |> recipes::step_normalize(recipes::all_numeric_predictors())
        if (input$step_dummy)     rec <- rec |> recipes::step_dummy(recipes::all_nominal_predictors())
        if (input$step_zv)        rec <- rec |> recipes::step_zv(recipes::all_predictors())

        # Modelo
        mod <- parsnip::linear_reg() |>
          parsnip::set_engine("lm") |>
          parsnip::set_mode("regression")

        # Workflow + last_fit
        wf <- workflows::workflow() |>
          workflows::add_recipe(rec) |>
          workflows::add_model(mod)

        resultado <- tune::last_fit(wf, sp)
        showNotification("Modelo ajustado correctamente.", type = "message", duration = 3)
        resultado

      }, error = function(e) {
        showNotification(paste("Error al ajustar el modelo:", conditionMessage(e)),
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
      req(modelo_ajustado(), ajuste_train())
      m    <- tune::collect_metrics(modelo_ajustado())
      at   <- ajuste_train()
      rmse_train <- round(sqrt(mean((at$y - at$fitted)^2)), 3)
      rsq_train  <- round(1 - sum((at$y - at$fitted)^2) / sum((at$y - mean(at$y))^2), 3)
      rmse_test  <- round(m$.estimate[m$.metric == "rmse"], 3)
      rsq_test   <- round(m$.estimate[m$.metric == "rsq"],  3)

      tagList(
        fluidRow(
          column(6,
            h6(style = "color:#1170AA; font-weight:700;",
               bsicons::bs_icon("circle-fill", class = "me-1"), "Entrenamiento (optimista)"),
            fluidRow(
              column(6, div(class = "metrica-card",
                div(class = "metrica-valor", style = "color:#1170AA;", rmse_train),
                div(class = "metrica-label", "RMSE"))),
              column(6, div(class = "metrica-card",
                div(class = "metrica-valor", style = "color:#1170AA;", rsq_train),
                div(class = "metrica-label", "R²")))
            )
          ),
          column(6,
            h6(style = "color:#C85200; font-weight:700;",
               bsicons::bs_icon("circle-fill", class = "me-1"), "Prueba (real)"),
            fluidRow(
              column(6, div(class = "metrica-card",
                div(class = "metrica-valor", style = "color:#C85200;", rmse_test),
                div(class = "metrica-label", "RMSE"))),
              column(6, div(class = "metrica-card",
                div(class = "metrica-valor", style = "color:#C85200;", rsq_test),
                div(class = "metrica-label", "R²")))
            )
          )
        ),
        br(),
        {
          dif <- abs(rsq_train - rsq_test)
          if (dif < 0.05)
            div(class = "alert alert-success small py-2",
              bsicons::bs_icon("check-circle", class = "me-1"),
              strong("El modelo generaliza muy bien"),
              " — R² entrenamiento: ", strong(rsq_train),
              ", R² prueba: ", strong(rsq_test),
              ", diferencia: ", strong(round(dif, 3)),
              ". Una diferencia menor a 0.05 indica excelente generalización.")
          else if (dif < 0.10)
            div(class = "alert alert-info small py-2",
              bsicons::bs_icon("info-circle", class = "me-1"),
              strong("Generalización aceptable"),
              " — R² entrenamiento: ", strong(rsq_train),
              ", R² prueba: ", strong(rsq_test),
              ", diferencia: ", strong(round(dif, 3)),
              ". Una diferencia entre 0.05 y 0.10 es pequeña y aceptable.")
          else
            div(class = "alert alert-warning small py-2",
              bsicons::bs_icon("exclamation-triangle", class = "me-1"),
              strong("Posible overfitting"),
              " — R² entrenamiento: ", strong(rsq_train),
              ", R² prueba: ", strong(rsq_test),
              ", diferencia: ", strong(round(dif, 3)),
              ". Una diferencia mayor a 0.10 sugiere memorización del entrenamiento.")
        },
        br(),
        div(class = "card",
          div(class = "card-header", "Criterios de interpretación (diferencia R² train − test)"),
          div(class = "card-body",
            tags$table(class = "table table-sm small mb-0",
              tags$tbody(
                tags$tr(
                  tags$td(bsicons::bs_icon("check-circle-fill", style = paste0("color:", colores$primario))),
                  tags$td(strong("< 0.05")), tags$td("El modelo generaliza muy bien")),
                tags$tr(
                  tags$td(bsicons::bs_icon("info-circle-fill", style = "color:#0d6efd")),
                  tags$td(strong("0.05 – 0.10")), tags$td("Generalización aceptable — diferencia pequeña")),
                tags$tr(
                  tags$td(bsicons::bs_icon("exclamation-triangle-fill", style = paste0("color:", colores$advertencia))),
                  tags$td(strong("> 0.10")), tags$td("Posible overfitting — considera reducir la complejidad"))
              )
            )
          )
        )
      )
    })

    # PESTAÑA 7: Diagnóstico
    # ════════════════════════════════════════════════

    ajuste_train <- reactive({
      req(modelo_ajustado())
      wf_fit <- modelo_ajustado()$.workflow[[1]]
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
        ggplot2::geom_point(alpha = 0.5, color = colores$primario) +
        ggplot2::geom_hline(yintercept = 0, color = colores$acento, linetype = "dashed") +
        ggplot2::geom_smooth(method = "loess", formula = y ~ x, se = FALSE, color = colores$peligro, linewidth = 0.8) +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = "Valores ajustados", y = "Residuos")
      plotly::ggplotly(p)
    })

    output$plot_qq <- plotly::renderPlotly({
      req(ajuste_train())
      resids <- ajuste_train()$residuals
      qq     <- qqnorm(resids, plot.it = FALSE)
      df     <- data.frame(theoretical = qq$x, sample = qq$y)
      p <- ggplot2::ggplot(df, ggplot2::aes(x = theoretical, y = sample)) +
        ggplot2::geom_point(alpha = 0.5, color = colores$primario) +
        ggplot2::geom_abline(color = colores$acento, linetype = "dashed") +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = "Cuantiles teóricos", y = "Cuantiles muestrales")
      plotly::ggplotly(p)
    })

    output$plot_scale_loc <- plotly::renderPlotly({
      req(ajuste_train())
      at <- ajuste_train()
      df <- data.frame(fitted = at$fitted, sqrt_resid = sqrt(abs(at$residuals)))
      p  <- ggplot2::ggplot(df, ggplot2::aes(x = fitted, y = sqrt_resid)) +
        ggplot2::geom_point(alpha = 0.5, color = colores$primario) +
        ggplot2::geom_smooth(method = "loess", formula = y ~ x, se = FALSE, color = colores$peligro, linewidth = 0.8) +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = "Valores ajustados", y = "√|Residuos estandarizados|")
      plotly::ggplotly(p)
    })

    output$plot_leverage <- plotly::renderPlotly({
      req(modelo_ajustado())
      wf_fit <- modelo_ajustado()$.workflow[[1]]
      train  <- rsample::training(split_datos())
      lm_fit <- wf_fit |> workflows::extract_fit_engine()
      hat    <- hatvalues(lm_fit)
      resids <- rstandard(lm_fit)
      df     <- data.frame(leverage = hat, std_resid = resids)
      p <- ggplot2::ggplot(df, ggplot2::aes(x = leverage, y = std_resid)) +
        ggplot2::geom_point(alpha = 0.5, color = colores$primario) +
        ggplot2::geom_hline(yintercept = c(-2, 2), linetype = "dashed",
                             color = colores$acento) +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = "Leverage", y = "Residuos estandarizados")
      plotly::ggplotly(p)
    })

    output$resumen_diagnostico <- renderUI({
      req(ajuste_train())
      resids <- ajuste_train()$residuals
      sw     <- shapiro.test(sample(resids, min(length(resids), 5000)))
      tagList(
        div(class = "card mt-3",
          div(class = "card-header", "Prueba de normalidad (Shapiro-Wilk)"),
          div(class = "card-body",
            p(paste("W =", round(sw$statistic, 4), "| p-valor =", round(sw$p.value, 4))),
            if (sw$p.value > 0.05)
              div(class = "alert alert-success",
                bsicons::bs_icon("check-circle"), " No se rechaza normalidad de residuos")
            else
              div(class = "alert alert-warning",
                bsicons::bs_icon("exclamation-triangle"), " Se rechaza normalidad de residuos")
          )
        )
      )
    })

    # PESTAÑA 8: Performance
    # ════════════════════════════════════════════════

    metrica_card_grande <- function(valor, label, sublabel, color) {
      div(class = "card mb-3",
        div(class = "card-body text-center",
          div(style = paste0("font-size: 0.85rem; font-weight: 600; color: ", color,
                             "; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 0.3rem;"),
              label),
          div(style = paste0("font-size: 2.4rem; font-weight: 800; color: ", color, "; line-height: 1;"),
              valor),
          div(style = "font-size: 0.78rem; color: #57606C; margin-top: 0.3rem;",
              sublabel)
        )
      )
    }

    output$card_rmse_train <- renderUI({
      req(ajuste_train())
      at   <- ajuste_train()
      rmse <- round(sqrt(mean((at$y - at$fitted)^2)), 3)
      metrica_card_grande(rmse, "RMSE — Entrenamiento",
        "Error cuadrático medio en train (optimista)", "#1170AA")
    })

    output$card_rmse_test <- renderUI({
      req(modelo_ajustado())
      m <- tune::collect_metrics(modelo_ajustado())
      v <- round(m$.estimate[m$.metric == "rmse"], 3)
      metrica_card_grande(v, "RMSE — Prueba",
        "Error cuadrático medio en test (real)", "#C85200")
    })

    output$card_rsq_train <- renderUI({
      req(ajuste_train())
      at  <- ajuste_train()
      rsq <- round(1 - sum((at$y - at$fitted)^2) / sum((at$y - mean(at$y))^2), 3)
      metrica_card_grande(rsq, "R² — Entrenamiento",
        "Varianza explicada en train (optimista)", "#1170AA")
    })

    output$card_rsq_test <- renderUI({
      req(modelo_ajustado())
      m <- tune::collect_metrics(modelo_ajustado())
      v <- round(m$.estimate[m$.metric == "rsq"], 3)
      metrica_card_grande(v, "R² — Prueba",
        "Varianza explicada en test (real)", "#C85200")
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
                else "Ajuste débil — considera Random Forest"
      div(class = paste("card p-3", clase),
        div(class = "d-flex align-items-center gap-2 mb-2", icono,
            h5(class = "mb-0", "Evaluación")),
        p(class = "mb-1", strong(msg)),
        p(class = "small text-muted mb-0",
          "R² (test): ", strong(round(rsq_v, 3)),
          " | RMSE (test): ", strong(round(rmse_v, 3)))
      )
    })

    # Cross-validation
    cv_resultado <- eventReactive(input$btn_cv, {
      req(split_datos(), input$var_respuesta, input$predictores)
      tryCatch({
        train <- rsample::training(split_datos())
        folds <- rsample::vfold_cv(train, v = input$cv_folds)

        rec <- recipes::recipe(
          as.formula(paste(input$var_respuesta, "~ .")),
          data = train
        )
        if (input$step_normalize) rec <- rec |> recipes::step_normalize(recipes::all_numeric_predictors())
        if (input$step_dummy)     rec <- rec |> recipes::step_dummy(recipes::all_nominal_predictors())
        if (input$step_zv)        rec <- rec |> recipes::step_zv(recipes::all_predictors())

        mod <- parsnip::linear_reg() |>
          parsnip::set_engine("lm") |>
          parsnip::set_mode("regression")

        wf <- workflows::workflow() |>
          workflows::add_recipe(rec) |>
          workflows::add_model(mod)

        res <- tune::fit_resamples(wf, folds,
          metrics = yardstick::metric_set(yardstick::rmse, yardstick::rsq, yardstick::mae))
        showNotification(paste0("CV completada (", input$cv_folds, " folds)."),
                         type = "message", duration = 3)
        res
      }, error = function(e) {
        showNotification(paste("Error en CV:", conditionMessage(e)),
                         type = "error", duration = 8)
        NULL
      })
    })

    output$resultados_cv <- renderUI({
      if (is.null(cv_resultado())) {
        return(div(class = "alert alert-info",
          bsicons::bs_icon("info-circle"), " ",
          "Ajusta el modelo primero y luego ejecuta la validación cruzada."))
      }
      m      <- tune::collect_metrics(cv_resultado())
      rmse_cv <- m[m$.metric == "rmse", ]
      rsq_cv  <- m[m$.metric == "rsq",  ]
      mae_cv  <- m[m$.metric == "mae",  ]
      fluidRow(
        column(4,
          div(class = "card mb-2",
            div(class = "card-body text-center",
              div(style = "font-size:0.85rem; font-weight:600; color:#FC7D0B; text-transform:uppercase;",
                  "RMSE — CV"),
              div(style = "font-size:2.4rem; font-weight:800; color:#FC7D0B; line-height:1;",
                  round(rmse_cv$mean, 3)),
              div(style = "font-size:0.78rem; color:#57606C;",
                  paste0("±", round(rmse_cv$std_err, 3), " (SE)"))
            )
          )
        ),
        column(4,
          div(class = "card mb-2",
            div(class = "card-body text-center",
              div(style = "font-size:0.85rem; font-weight:600; color:#FC7D0B; text-transform:uppercase;",
                  "R² — CV"),
              div(style = "font-size:2.4rem; font-weight:800; color:#FC7D0B; line-height:1;",
                  round(rsq_cv$mean, 3)),
              div(style = "font-size:0.78rem; color:#57606C;",
                  paste0("±", round(rsq_cv$std_err, 3), " (SE)"))
            )
          )
        ),
        column(4,
          div(class = "card mb-2",
            div(class = "card-body text-center",
              div(style = "font-size:0.85rem; font-weight:600; color:#FC7D0B; text-transform:uppercase;",
                  "MAE — CV"),
              div(style = "font-size:2.4rem; font-weight:800; color:#FC7D0B; line-height:1;",
                  round(mae_cv$mean, 3)),
              div(style = "font-size:0.78rem; color:#57606C;",
                  paste0("±", round(mae_cv$std_err, 3), " (SE)"))
            )
          )
        )
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
      # collect_predictions includes the response variable directly
      if (!obs_col %in% names(df)) {
        obs_col <- names(df)[!names(df) %in% c(".pred", ".row", ".config", "id")][1]
      }
      y_col   <- ".pred"
      lim <- range(c(df[[obs_col]], df[[y_col]]), na.rm = TRUE)
      p <- ggplot2::ggplot(df, ggplot2::aes(x = .data[[obs_col]], y = .data[[y_col]])) +
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
      if (!obs_col %in% names(df)) {
        obs_col <- names(df)[!names(df) %in% c(".pred", ".row", ".config", "id")][1]
      }
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
      if (!obs_col %in% names(df)) {
        obs_col <- names(df)[!names(df) %in% c(".pred", ".row", ".config", "id")][1]
      }
      df$Predicho <- round(df$.pred, 3)
      df$Residuo  <- round(df[[obs_col]] - df$.pred, 3)
      out <- df[, c(obs_col, "Predicho", "Residuo")]
      names(out)[1] <- "Observado"
      DT::datatable(out,
        options = list(pageLength = 10, scrollX = TRUE, dom = "tip"),
        rownames = FALSE
      )
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
        ggplot2::labs(x = "Aumento en RMSE (permutación)", y = NULL,
                      title = "Importancia por permutación")
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
      vars <- input$predictores
      selectInput(ns("var_pdp"), "Variable para PDP", choices = vars, selected = vars[1])
    })

    output$plot_pdp <- plotly::renderPlotly({
      req(modelo_ajustado(), input$var_pdp)
      wf_fit <- modelo_ajustado()$.workflow[[1]]
      train  <- rsample::training(split_datos())
      var    <- input$var_pdp
      n_grid <- input$grid_pdp

      if (is.numeric(train[[var]])) {
        grid_vals <- seq(min(train[[var]], na.rm = TRUE),
                         max(train[[var]], na.rm = TRUE),
                         length.out = n_grid)
      } else {
        grid_vals <- unique(train[[var]])
      }

      pdp_df <- do.call(rbind, lapply(grid_vals, function(v) {
        df_tmp <- train
        df_tmp[[var]] <- v
        pred <- mean(predict(wf_fit, df_tmp)$.pred, na.rm = TRUE)
        data.frame(x = v, y_hat = pred)
      }))

      p <- ggplot2::ggplot(pdp_df, ggplot2::aes(x = x, y = y_hat)) +
        ggplot2::geom_line(color = colores$primario, linewidth = 1.2) +
        ggplot2::geom_point(color = colores$acento, size = 2) +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = var, y = paste("Predicción promedio de", input$var_respuesta),
                      title = paste("PDP —", var))
      plotly::ggplotly(p)
    })

    # PESTAÑA 12: Código R
    # ════════════════════════════════════════════════

    codigo_r <- reactive({
      req(input$var_respuesta, input$predictores)
      steps <- c()
      if (input$step_normalize) steps <- c(steps, "  step_normalize(all_numeric_predictors()) |>")
      if (input$step_dummy)     steps <- c(steps, "  step_dummy(all_nominal_predictors()) |>")
      if (input$step_zv)        steps <- c(steps, "  step_zv(all_predictors()) |>")
      steps_str <- if (length(steps) > 0) paste(steps, collapse = "\n") else "  # sin pasos adicionales"

      paste0(
        encabezado_script("StatML", "Regresión lineal"),
        "library(tidymodels)\n\n",
        "# Cargar datos\n",
        "# datos <- read_excel('tus_datos.xlsx')\n\n",
        "# División train/test\n",
        "set.seed(", input$semilla, ")\n",
        "split <- initial_split(datos, prop = ", input$prop_train, ")\n",
        "train <- training(split)\n",
        "test  <- testing(split)\n\n",
        "# Receta de preprocesamiento\n",
        "receta <- recipe(", input$var_respuesta, " ~ ",
        paste(input$predictores, collapse = " + "), ", data = train) |>\n",
        steps_str, "\n\n",
        "# Modelo\n",
        "modelo <- linear_reg() |>\n",
        "  set_engine('", input$engine_lm, "') |>\n",
        "  set_mode('regression')\n\n",
        "# Workflow\n",
        "wf <- workflow() |>\n",
        "  add_recipe(receta) |>\n",
        "  add_model(modelo)\n\n",
        "# Ajuste y evaluación\n",
        "ajuste   <- last_fit(wf, split)\n",
        "metricas <- collect_metrics(ajuste)\n",
        "preds    <- collect_predictions(ajuste)\n\n",
        "# Importancia de variables\n",
        "library(vip)\n",
        "vi(ajuste$.workflow[[1]])\n"
      )
    })

    output$codigo_reproducible <- renderText({
      req(codigo_r())
      codigo_r()
    })

    output$btn_descargar_codigo <- downloadHandler(
      filename = function() paste0("StatML_lm_", Sys.Date(), ".R"),
      content  = function(file) writeLines(codigo_r(), file)
    )

  }) # /moduleServer
} # /mod_lm_ml_server
