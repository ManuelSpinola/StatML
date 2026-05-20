# ============================================================
# mod_glm_ml.R — Clasificación GLM (Regresión Logística)
# StatML · StatSuite
# Manuel Spínola · ICOMVIS · UNA · Costa Rica
# ============================================================

# ── UI ──────────────────────────────────────────────────────
#' @noRd
mod_glm_ml_ui <- function(id) {
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
              h4(tagList(bsicons::bs_icon("diagram-3", class = "me-2"),
                         "Clasificación con Regresión Logística")),
              p(class = "lead",
                "La regresión logística es el modelo de clasificación binaria más utilizado
                 en ecología y ciencias de la vida. Modela la ",
                strong("probabilidad de pertenencia a una clase"),
                " en función de los predictores."),
              hr(),
              h5("De regresión a clasificación"),
              p(class = "small",
                "A diferencia de LM que predice un valor continuo, aquí la variable
                 respuesta es ", strong("binaria (0/1)"), ": presencia/ausencia,
                 supervivencia/muerte, éxito/fracaso. El modelo estima la probabilidad
                 P(Y=1|X) usando la función logística:"),
              div(class = "codigo-bloque",
                "P(Y=1) = 1 / (1 + e^-(β₀ + β₁X₁ + ... + βₙXₙ))"
              ),
              br(),
              fluidRow(
                column(6,
                  div(class = "card mb-3",
                    div(class = "card-header",
                        tagList(bsicons::bs_icon("check2-circle"), " Enfoque inferencial (StatModels)")),
                    div(class = "card-body",
                      tags$ul(class = "small mb-0",
                        tags$li("¿Qué variables son significativas?"),
                        tags$li("Odds ratios e intervalos de confianza"),
                        tags$li("Prueba de bondad de ajuste"),
                        tags$li("Interpretación de coeficientes")
                      )
                    )
                  )
                ),
                column(6,
                  div(class = "card mb-3",
                    div(class = "card-header",
                        tagList(bsicons::bs_icon("robot"), " Enfoque predictivo (StatML)")),
                    div(class = "card-body",
                      tags$ul(class = "small mb-0",
                        tags$li("¿Qué tan bien clasifica?"),
                        tags$li("AUC, Accuracy, F1, Sensibilidad"),
                        tags$li("Curva ROC en datos de prueba"),
                        tags$li("Umbral de clasificación óptimo")
                      )
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
                    tags$li("Ajustar modelo logístico"),
                    tags$li("Evaluar con AUC y curva ROC"),
                    tags$li("Seleccionar umbral de clasificación"),
                    tags$li("Interpretar importancia y PDP"),
                    tags$li("Comparar con RF Clasificación")
                  )
                )
              ),
              div(class = "card",
                div(class = "card-header",
                    tagList(bsicons::bs_icon("exclamation-triangle"), " Limitaciones")),
                div(class = "card-body",
                  tags$ul(class = "small mb-0",
                    tags$li("Asume relaciones lineales en log-odds"),
                    tags$li("Sensible a separación perfecta"),
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
          bslib::navset_pill(

            bslib::nav_panel("Train / Test",
              br(),
              p("El mismo principio que en regresión: evaluar en datos que el modelo
                nunca vio durante el entrenamiento."),
              br(),
              div(style = "max-width: 600px;",
                div(style = "display: flex; height: 60px; border-radius: 8px; overflow: hidden; border: 1px solid #C8D9EC;",
                  div(style = "background: #1170AA; width: 80%; display: flex; align-items: center; justify-content: center;",
                    span(style = "color: #ffffff; font-weight: 700; font-size: 1rem;", "Entrenamiento (80%)")
                  ),
                  div(style = "background: #C85200; width: 20%; display: flex; align-items: center; justify-content: center;",
                    span(style = "color: #ffffff; font-weight: 700; font-size: 1rem;", "Prueba (20%)")
                  )
                ),
                br(),
                p(class = "small text-muted",
                  strong("Importante:"), " En clasificación es recomendable usar ",
                  strong("muestreo estratificado"), " para que la proporción de clases
                   sea similar en train y test. tidymodels lo hace automáticamente con ",
                  code("initial_split(..., strata = variable_respuesta)"), ".")
              )
            ),

            bslib::nav_panel("Métricas",
              br(),
              fluidRow(
                column(6,
                  div(class = "metrica-card mb-3",
                    div(class = "metrica-label", "AUC-ROC"),
                    div(class = "metrica-valor", "0–1"),
                    p(class = "small mt-2",
                      "Área bajo la curva ROC. Mide la capacidad discriminante
                       independientemente del umbral. 0.5 = azar, 1.0 = perfecto.")
                  )
                ),
                column(6,
                  div(class = "metrica-card mb-3",
                    div(class = "metrica-label", "Accuracy"),
                    div(class = "metrica-valor", "(TP+TN)/N"),
                    p(class = "small mt-2",
                      "Proporción de clasificaciones correctas. Puede ser engañoso
                       con clases desbalanceadas.")
                  )
                )
              ),
              fluidRow(
                column(6,
                  div(class = "metrica-card mb-3",
                    div(class = "metrica-label", "Sensibilidad"),
                    div(class = "metrica-valor", "TP/(TP+FN)"),
                    p(class = "small mt-2",
                      "Proporción de positivos correctamente identificados.
                       Crucial cuando el costo de falsos negativos es alto.")
                  )
                ),
                column(6,
                  div(class = "metrica-card mb-3",
                    div(class = "metrica-label", "Especificidad"),
                    div(class = "metrica-valor", "TN/(TN+FP)"),
                    p(class = "small mt-2",
                      "Proporción de negativos correctamente identificados.
                       Complementaria a la sensibilidad.")
                  )
                )
              )
            ),

            bslib::nav_panel("Umbral",
              br(),
              p("El modelo logístico predice ", strong("probabilidades (0 a 1)"),
                ". Para clasificar en 0 o 1 se necesita un ",
                strong("umbral (threshold)"), ". El umbral por defecto es 0.5,
                pero puede ajustarse según el contexto:"),
              br(),
              fluidRow(
                column(6,
                  div(class = "card sem-ok",
                    div(class = "card-body",
                      h6(bsicons::bs_icon("arrow-down-circle"), " Umbral bajo (ej. 0.3)"),
                      p(class = "small mb-0",
                        "Mayor sensibilidad — detecta más presencias.
                         Útil cuando el costo de falsos negativos es alto
                         (ej. especie en peligro).")
                    )
                  )
                ),
                column(6,
                  div(class = "card sem-warn",
                    div(class = "card-body",
                      h6(bsicons::bs_icon("arrow-up-circle"), " Umbral alto (ej. 0.7)"),
                      p(class = "small mb-0",
                        "Mayor especificidad — menos falsas alarmas.
                         Útil cuando el costo de falsos positivos es alto.")
                    )
                  )
                )
              ),
              br(),
              p(class = "small text-muted",
                "La curva ROC muestra el trade-off entre sensibilidad y especificidad
                 para todos los umbrales posibles.")
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
                        "Presencia/ausencia de aves"    = "aves_pa_paisaje",
                        "Presencia/ausencia de ranas"   = "frogs",
                        "Supervivencia en el Titanic"   = "titanic_ml",
                        "Cargar mis propios datos"      = "propio"
                      ),
                      selected = "aves_pa_paisaje"
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
                      "La variable respuesta debe ser binaria (0/1 o factor con 2 niveles)."),
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
                "La variable respuesta debe ser ", strong("Factor"),
                " con exactamente 2 niveles."
              ),
              bslib::layout_columns(
                col_widths = c(10, 2),
                uiOutput(ns("tabla_tipos")),
                div(class = "pt-2",
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
                    choices = c("Dispersión/Jitter" = "scatter",
                                "Boxplot"           = "boxplot",
                                "Barras (proporción)" = "prop",
                                "Correlación"       = "corr")
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
              h5("Balance de clases"),
              uiOutput(ns("balance_clases"))
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
                    min = 0.5, max = 0.9, value = 0.8, step = 0.05, post = "%"
                  ),
                  numericInput(ns("semilla"), "Semilla",
                               value = 123, min = 1, step = 1),
                  checkboxInput(ns("strata"),
                    "Muestreo estratificado (recomendado)", value = TRUE)
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
                div(class = "card-header", "Especificación"),
                div(class = "card-body",
                  p(class = "small text-muted",
                    "Regresión logística (GLM binomial con función de enlace logit).",
                    br(), "Motor: ", strong("glm"), " (stats)")
                )
              ),
              div(class = "card mb-3",
                div(class = "card-header", "Umbral de clasificación"),
                div(class = "card-body",
                  sliderInput(ns("umbral"),
                    label = "Umbral (threshold)",
                    min = 0.1, max = 0.9, value = 0.5, step = 0.05
                  ),
                  p(class = "small text-muted mb-0",
                    "P(Y=1) ≥ umbral → clasifica como 1")
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
            "Para GLM logístico el diagnóstico se centra en la calibración del modelo
             y la distribución de probabilidades predichas por clase."),
          fluidRow(
            column(6,
              h6("Probabilidades predichas por clase"),
              plotly::plotlyOutput(ns("plot_prob_clases"), height = "300px")
            ),
            column(6,
              h6("Curva de calibración"),
              plotly::plotlyOutput(ns("plot_calibracion"), height = "300px")
            )
          ),
          br(),
          fluidRow(
            column(6,
              h6("Residuos de devianza"),
              plotly::plotlyOutput(ns("plot_residuos_dev"), height = "300px")
            ),
            column(6,
              h6("Leverage vs Residuos"),
              plotly::plotlyOutput(ns("plot_leverage"), height = "300px")
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

          # ── Hold-out ──────────────────────────────
          div(style = "border-left: 4px solid #1170AA; padding-left: 1rem; margin-bottom: 1.5rem;",
            h4(style = "color: #1170AA; font-weight: 700; margin-bottom: 0.2rem;",
               bsicons::bs_icon("diagram-2", class = "me-2"), "Hold-out (Train / Test)"),
            p(class = "small text-muted mb-0",
              "Comparar métricas en train y test permite detectar overfitting.
               Valores muy superiores en train indican que el modelo memoriza en lugar de generalizar.")
          ),
          fluidRow(
            column(4, uiOutput(ns("card_auc_train"))),
            column(4, uiOutput(ns("card_auc_test"))),
            column(4, uiOutput(ns("semaforo_performance")))
          ),
          br(),
          fluidRow(
            column(4, uiOutput(ns("card_acc_train"))),
            column(4, uiOutput(ns("card_acc_test")))
          ),

          hr(),

          # ── Matriz de confusión + métricas extendidas ──
          div(style = "border-left: 4px solid #5FA2CE; padding-left: 1rem; margin-bottom: 1.5rem;",
            h4(style = "color: #5FA2CE; font-weight: 700; margin-bottom: 0.2rem;",
               bsicons::bs_icon("grid-3x3", class = "me-2"), "Matriz de confusión y métricas")
          ),
          fluidRow(
            column(5, uiOutput(ns("matriz_confusion"))),
            column(7, uiOutput(ns("metricas_extendidas")))
          ),

          hr(),

          # ── Bondad de ajuste ──────────────────────────
          div(style = "border-left: 4px solid #9F8B75; padding-left: 1rem; margin-bottom: 1.5rem;",
            h4(style = "color: #9F8B75; font-weight: 700; margin-bottom: 0.2rem;",
               bsicons::bs_icon("clipboard-check", class = "me-2"), "Bondad de ajuste"),
            p(class = "small text-muted mb-0",
              "La prueba de Hosmer-Lemeshow evalúa si las probabilidades predichas
               calibran bien con las frecuencias observadas.")
          ),
          fluidRow(
            column(5, uiOutput(ns("hosmer_lemeshow"))),
            column(7,
              h6("Curva ROC (datos de prueba)"),
              plotly::plotlyOutput(ns("plot_roc_performance"), height = "280px")
            )
          ),

          hr(),

          # ── Cross-validation ──────────────────────────
          div(style = "border-left: 4px solid #FC7D0B; padding-left: 1rem; margin-bottom: 1.5rem;",
            h4(style = "color: #FC7D0B; font-weight: 700; margin-bottom: 0.2rem;",
               bsicons::bs_icon("arrow-repeat", class = "me-2"), "Validación cruzada (CV)")
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
            column(8, uiOutput(ns("resultados_cv")))
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
            column(6,
              h6("Curva ROC (datos de prueba)"),
              plotly::plotlyOutput(ns("plot_roc"), height = "400px")
            ),
            column(6,
              h6("Distribución de probabilidades predichas"),
              plotly::plotlyOutput(ns("plot_prob_hist"), height = "400px")
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
                "Importancia por permutación basada en AUC. Método agnóstico —
                 comparable entre GLM y RF Clasificación."),
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
            "Los PDP muestran cómo varía la probabilidad predicha P(Y=1)
             al cambiar un predictor, promediando sobre los demás."),
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
} # /mod_glm_ml_ui

# ── SERVER ───────────────────────────────────────────────────
#' @noRd
mod_glm_ml_server <- function(id) {
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
          showNotification(paste("Error al leer:", conditionMessage(e)),
                           type = "error", duration = 6)
          NULL
        })
      }
    })

    output$info_dataset <- renderUI({
      fuente <- input$fuente_datos
      if (is.null(fuente) || fuente == "propio") return(NULL)
      descripciones <- list(
        aves_pa_paisaje = "Presencia/ausencia de aves en 800 sitios del paisaje. Variables: cobertura forestal, altitud, temperatura, precipitaci\u00f3n, tipo de h\u00e1bitat y protecci\u00f3n. Datos simulados con relaciones no lineales.",
        frogs           = "Presencia/ausencia de ranas en 212 sitios de Australia. Variables topogr\u00e1ficas, clim\u00e1ticas y de h\u00e1bitat. Dataset cl\u00e1sico de modelado de distribuci\u00f3n de especies.",
        titanic_ml      = "Supervivencia de 2207 pasajeros del Titanic. Variables: g\u00e9nero, edad, clase, puerto de embarque, tarifa y n\u00famero de familiares a bordo."
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
          style = "background:#fff; border:1px solid #C8D9EC; border-radius:8px; padding:1rem; text-align:center;",
          div(style = "font-size:1.8rem; font-weight:700; color:#1170AA;", nrow(df)),
          div(style = "font-size:0.82rem; color:#57606C;", "Observaciones")
        )),
        column(4, div(
          style = "background:#fff; border:1px solid #C8D9EC; border-radius:8px; padding:1rem; text-align:center;",
          div(style = "font-size:1.8rem; font-weight:700; color:#FC7D0B;", n_num),
          div(style = "font-size:0.82rem; color:#57606C;", "Num\u00e9ricas")
        )),
        column(4, div(
          style = "background:#fff; border:1px solid #C8D9EC; border-radius:8px; padding:1rem; text-align:center;",
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
      vars_bin <- names(datos_raw())[sapply(datos_raw(), function(x)
        is.factor(x) && nlevels(x) == 2 || (is.numeric(x) && all(x %in% c(0, 1), na.rm = TRUE)))]
      if (length(vars_bin) == 0) vars_bin <- names(datos_raw())[1]
      selectInput(ns("var_resp_explorar"), "Variable respuesta (Y binaria)",
                  choices = vars_bin, selected = vars_bin[1])
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

      x_is_cat <- is.factor(df[[x_v]]) || is.character(df[[x_v]])

      p <- switch(input$tipo_grafico_explorar,
        "scatter" = {
          geom_pts <- if (x_is_cat)
            ggplot2::geom_jitter(alpha = 0.4, width = 0.2, height = 0.05)
          else
            ggplot2::geom_jitter(alpha = 0.4, width = 0, height = 0.05)
          base <- if (!is.null(col))
            ggplot2::ggplot(df, ggplot2::aes(x = .data[[x_v]], y = as.numeric(as.character(.data[[y_v]])),
                                              color = .data[[col]])) +
              geom_pts + scale_color_tableau_cb()
          else
            ggplot2::ggplot(df, ggplot2::aes(x = .data[[x_v]], y = as.numeric(as.character(.data[[y_v]])))) +
              geom_pts + ggplot2::geom_smooth(method = "glm", formula = y ~ x,
                method.args = list(family = "binomial"), se = TRUE, color = colores$acento)
          base + ggplot2::labs(y = paste("P(", y_v, "= 1)"))
        },
        "boxplot" = ggplot2::ggplot(df,
            ggplot2::aes(x = as.factor(.data[[y_v]]), y = .data[[x_v]],
                         fill = as.factor(.data[[y_v]]))) +
          ggplot2::geom_boxplot() + scale_fill_tableau_cb() +
          ggplot2::labs(x = y_v, fill = y_v),
        "prop" = {
          df2 <- df |>
            dplyr::group_by(.data[[x_v]], .data[[y_v]]) |>
            dplyr::summarise(n = dplyr::n(), .groups = "drop") |>
            dplyr::group_by(.data[[x_v]]) |>
            dplyr::mutate(prop = n / sum(n))
          ggplot2::ggplot(df2, ggplot2::aes(x = .data[[x_v]], y = prop,
                                             fill = as.factor(.data[[y_v]]))) +
            ggplot2::geom_col(position = "stack") +
            scale_fill_tableau_cb() +
            ggplot2::labs(y = "Proporción", fill = y_v)
        },
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

    output$balance_clases <- renderUI({
      req(datos_raw(), input$var_resp_explorar)
      df  <- datos_raw()
      y_v <- input$var_resp_explorar
      tab <- table(df[[y_v]])
      n   <- sum(tab)
      fluidRow(
        lapply(seq_along(tab), function(i) {
          clase <- names(tab)[i]
          pct   <- round(100 * tab[i] / n, 1)
          color <- if (i == 1) colores$primario else colores$acento
          column(3, div(
            style = paste0("background:#fff; border:1px solid #C8D9EC; border-radius:8px;
                            padding:1rem; text-align:center;"),
            div(style = paste0("font-size:1.8rem; font-weight:700; color:", color, ";"),
                tab[i]),
            div(style = "font-size:0.82rem; color:#57606C;",
                paste0("Clase ", clase, " (", pct, "%)"))
          ))
        })
      )
    })

    # PESTAÑA 5: Preprocesamiento
    # ════════════════════════════════════════════════

    output$sel_var_respuesta <- renderUI({
      req(datos_raw())
      df <- datos_raw()
      vars_bin <- names(df)[sapply(df, function(x)
        (is.factor(x) && nlevels(x) == 2) ||
        (is.numeric(x) && all(x %in% c(0, 1), na.rm = TRUE)))]
      if (length(vars_bin) == 0) vars_bin <- names(df)[1]
      selectInput(ns("var_respuesta"), "Variable respuesta (Y binaria)",
                  choices = vars_bin, selected = vars_bin[1])
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
      df2  <- df[, cols]
      # Ensure response is factor
      df2[[input$var_respuesta]] <- as.factor(df2[[input$var_respuesta]])
      df2
    })

    split_datos <- reactive({
      req(datos_modelo())
      set.seed(input$semilla)
      if (isTRUE(input$strata))
        rsample::initial_split(datos_modelo(), prop = input$prop_train,
                               strata = input$var_respuesta)
      else
        rsample::initial_split(datos_modelo(), prop = input$prop_train)
    })

    output$resumen_preprocesamiento <- renderUI({
      req(split_datos())
      sp    <- split_datos()
      train <- rsample::training(sp)
      tab   <- table(train[[input$var_respuesta]])
      tagList(
        fluidRow(
          column(6,
            div(class = "card",
              div(class = "card-header", "Entrenamiento"),
              div(class = "card-body",
                div(class = "metrica-card",
                  div(class = "metrica-valor", nrow(train)),
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
          div(class = "card-header", "Balance de clases en entrenamiento"),
          div(class = "card-body",
            fluidRow(
              lapply(seq_along(tab), function(i) {
                column(4, div(class = "metrica-card",
                  div(class = "metrica-valor", tab[i]),
                  div(class = "metrica-label", paste("Clase", names(tab)[i]))))
              })
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

        rec <- recipes::recipe(
          as.formula(paste(input$var_respuesta, "~ .")),
          data = train
        )
        if (input$step_normalize) rec <- rec |> recipes::step_normalize(recipes::all_numeric_predictors())
        if (input$step_dummy)     rec <- rec |> recipes::step_dummy(recipes::all_nominal_predictors())
        if (input$step_zv)        rec <- rec |> recipes::step_zv(recipes::all_predictors())

        mod <- parsnip::logistic_reg() |>
          parsnip::set_engine("glm") |>
          parsnip::set_mode("classification")

        wf <- workflows::workflow() |>
          workflows::add_recipe(rec) |>
          workflows::add_model(mod)

        resultado <- tune::last_fit(wf, sp,
          metrics = yardstick::metric_set(
            yardstick::roc_auc, yardstick::accuracy,
            yardstick::sensitivity, yardstick::specificity))

        showNotification("Modelo ajustado correctamente.", type = "message", duration = 3)
        resultado
      }, error = function(e) {
        showNotification(paste("Error:", conditionMessage(e)),
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
          column(3, div(class = "metrica-card",
            div(class = "metrica-valor",
                round(m$.estimate[m$.metric == "roc_auc"], 3)),
            div(class = "metrica-label", "AUC"))),
          column(3, div(class = "metrica-card",
            div(class = "metrica-valor",
                round(m$.estimate[m$.metric == "accuracy"], 3)),
            div(class = "metrica-label", "Accuracy"))),
          column(3, div(class = "metrica-card",
            div(class = "metrica-valor",
                round(m$.estimate[m$.metric == "sensitivity"], 3)),
            div(class = "metrica-label", "Sensibilidad"))),
          column(3, div(class = "metrica-card",
            div(class = "metrica-valor",
                round(m$.estimate[m$.metric == "specificity"], 3)),
            div(class = "metrica-label", "Especificidad")))
        )
      )
    })

    # PESTAÑA 7: Diagnóstico
    # ════════════════════════════════════════════════

    preds_train <- reactive({
      req(modelo_ajustado())
      wf_fit <- tune::extract_workflow(modelo_ajustado())
      train  <- rsample::training(split_datos())
      probs  <- predict(wf_fit, train, type = "prob")
      clase  <- train[[input$var_respuesta]]
      niveles <- levels(clase)
      prob_pos <- probs[[paste0(".pred_", niveles[2])]]
      list(prob = prob_pos, clase = clase, niveles = niveles)
    })

    output$plot_prob_clases <- plotly::renderPlotly({
      req(preds_train())
      pt <- preds_train()
      df <- data.frame(prob = pt$prob, clase = pt$clase)
      p  <- ggplot2::ggplot(df, ggplot2::aes(x = prob, fill = clase)) +
        ggplot2::geom_density(alpha = 0.5) +
        scale_fill_tableau_cb() +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = "Probabilidad predicha P(Y=1)", y = "Densidad", fill = "Clase")
      plotly::ggplotly(p)
    })

    output$plot_calibracion <- plotly::renderPlotly({
      req(preds_train())
      pt  <- preds_train()
      df  <- data.frame(prob = pt$prob,
                         obs  = as.numeric(pt$clase) - 1)
      bins <- cut(df$prob, breaks = seq(0, 1, by = 0.1), include.lowest = TRUE)
      cal  <- aggregate(obs ~ bins, data = df, FUN = mean)
      mids <- seq(0.05, 0.95, by = 0.1)
      cal$mid <- mids[seq_len(nrow(cal))]
      p <- ggplot2::ggplot(cal, ggplot2::aes(x = mid, y = obs)) +
        ggplot2::geom_point(color = colores$primario, size = 3) +
        ggplot2::geom_line(color = colores$primario) +
        ggplot2::geom_abline(slope = 1, intercept = 0,
                              linetype = "dashed", color = colores$acento) +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = "Probabilidad predicha", y = "Proporción observada",
                      title = "Calibración (perfecto = diagonal)")
      plotly::ggplotly(p)
    })

    output$plot_residuos_dev <- plotly::renderPlotly({
      req(modelo_ajustado())
      tryCatch({
        wf_fit <- modelo_ajustado()$.workflow[[1]]
        glm_fit <- workflows::extract_fit_engine(wf_fit)
        df <- data.frame(
          fitted   = fitted(glm_fit),
          residuals = residuals(glm_fit, type = "deviance")
        )
        p <- ggplot2::ggplot(df, ggplot2::aes(x = fitted, y = residuals)) +
          ggplot2::geom_point(alpha = 0.4, color = colores$primario) +
          ggplot2::geom_hline(yintercept = 0, color = colores$acento, linetype = "dashed") +
          ggplot2::geom_smooth(method = "loess", formula = y ~ x, se = FALSE,
                                color = colores$peligro, linewidth = 0.8) +
          ggplot2::theme_minimal() +
          ggplot2::labs(x = "Valores ajustados", y = "Residuos de devianza")
        plotly::ggplotly(p)
      }, error = function(e) plotly::plot_ly() |>
        plotly::add_annotations(text = "No disponible", showarrow = FALSE))
    })

    output$plot_leverage <- plotly::renderPlotly({
      req(modelo_ajustado())
      tryCatch({
        wf_fit  <- modelo_ajustado()$.workflow[[1]]
        glm_fit <- workflows::extract_fit_engine(wf_fit)
        df <- data.frame(
          leverage  = hatvalues(glm_fit),
          std_resid = rstandard(glm_fit)
        )
        p <- ggplot2::ggplot(df, ggplot2::aes(x = leverage, y = std_resid)) +
          ggplot2::geom_point(alpha = 0.4, color = colores$primario) +
          ggplot2::geom_hline(yintercept = c(-2, 2), linetype = "dashed",
                               color = colores$acento) +
          ggplot2::theme_minimal() +
          ggplot2::labs(x = "Leverage", y = "Residuos estandarizados")
        plotly::ggplotly(p)
      }, error = function(e) plotly::plot_ly() |>
        plotly::add_annotations(text = "No disponible", showarrow = FALSE))
    })

    # PESTAÑA 8: Performance
    # ════════════════════════════════════════════════

    metrica_card_clas <- function(valor, label, sublabel, color) {
      div(class = "card mb-3",
        div(class = "card-body text-center",
          div(style = paste0("font-size:0.8rem; font-weight:600; color:", color,
                             "; text-transform:uppercase; letter-spacing:0.05em; margin-bottom:0.3rem;"),
              label),
          div(style = paste0("font-size:2.2rem; font-weight:800; color:", color, "; line-height:1;"),
              valor),
          div(style = "font-size:0.75rem; color:#57606C; margin-top:0.3rem;", sublabel)
        )
      )
    }

    # ── Helpers de métricas train ─────────────────────────────
    metricas_train_clas <- reactive({
      req(modelo_ajustado(), input$var_respuesta)
      wf_fit  <- tune::extract_workflow(modelo_ajustado())
      train   <- rsample::training(split_datos())
      niveles <- levels(train[[input$var_respuesta]])
      probs   <- predict(wf_fit, train, type = "prob")
      preds   <- predict(wf_fit, train)
      prob_col <- paste0(".pred_", niveles[2])
      auc_t <- tryCatch(
        as.numeric(pROC::auc(pROC::roc(
          response  = train[[input$var_respuesta]],
          predictor = probs[[prob_col]],
          levels = niveles, direction = "<", quiet = TRUE))),
        error = function(e) NA)
      acc_t <- mean(preds$.pred_class == train[[input$var_respuesta]], na.rm = TRUE)
      list(auc = round(auc_t, 3), acc = round(acc_t, 3))
    })

    output$card_auc_train <- renderUI({
      req(metricas_train_clas())
      metrica_card_clas(metricas_train_clas()$auc,
        "AUC-ROC — Entrenamiento", "Capacidad discriminante en train (optimista)", "#1170AA")
    })

    output$card_auc_test <- renderUI({
      req(modelo_ajustado())
      m <- tune::collect_metrics(modelo_ajustado())
      v <- round(m$.estimate[m$.metric == "roc_auc"], 3)
      metrica_card_clas(v, "AUC-ROC — Prueba", "Capacidad discriminante en test (real)", "#C85200")
    })

    output$card_acc_train <- renderUI({
      req(metricas_train_clas())
      metrica_card_clas(metricas_train_clas()$acc,
        "Accuracy — Entrenamiento", "Clasificaciones correctas en train (optimista)", "#1170AA")
    })

    output$card_acc_test <- renderUI({
      req(modelo_ajustado())
      m <- tune::collect_metrics(modelo_ajustado())
      v <- round(m$.estimate[m$.metric == "accuracy"], 3)
      metrica_card_clas(v, "Accuracy — Prueba", "Clasificaciones correctas en test (real)", "#C85200")
    })

    output$semaforo_performance <- renderUI({
      req(modelo_ajustado())
      m    <- tune::collect_metrics(modelo_ajustado())
      auc  <- m$.estimate[m$.metric == "roc_auc"]
      acc  <- m$.estimate[m$.metric == "accuracy"]
      clase <- if (auc >= 0.8) "sem-ok" else if (auc >= 0.6) "sem-warn" else "sem-bad"
      icono <- if (auc >= 0.8) bsicons::bs_icon("check-circle-fill")
               else if (auc >= 0.6) bsicons::bs_icon("exclamation-triangle-fill")
               else bsicons::bs_icon("x-circle-fill")
      msg   <- if (auc >= 0.8) "Buena capacidad discriminante"
               else if (auc >= 0.6) "Discriminación moderada"
               else "Discriminación débil — considera RF"
      div(class = paste("card p-3", clase),
        div(class = "d-flex align-items-center gap-2 mb-2", icono,
            h5(class = "mb-0", "Evaluación")),
        p(class = "mb-1", strong(msg)),
        p(class = "small text-muted mb-0",
          "AUC (test): ", strong(round(auc, 3)),
          " | Accuracy (test): ", strong(round(acc, 3)))
      )
    })

    output$metricas_extendidas <- renderUI({
      req(modelo_ajustado(), input$umbral)
      tryCatch({
        wf_fit  <- tune::extract_workflow(modelo_ajustado())
        test    <- rsample::testing(split_datos())
        niveles <- levels(test[[input$var_respuesta]])
        probs   <- predict(wf_fit, test, type = "prob")
        prob_col <- paste0(".pred_", niveles[2])
        pred_cls <- factor(ifelse(probs[[prob_col]] >= input$umbral,
                                  niveles[2], niveles[1]), levels = niveles)
        obs <- test[[input$var_respuesta]]

        # Compute metrics
        df_res <- data.frame(truth = obs, estimate = pred_cls,
                             prob = probs[[prob_col]])
        sens <- round(yardstick::sensitivity_vec(obs, pred_cls, event_level = "second"), 3)
        spec <- round(yardstick::specificity_vec(obs, pred_cls, event_level = "second"), 3)
        ppv  <- round(yardstick::ppv_vec(obs, pred_cls, event_level = "second"), 3)
        npv  <- round(yardstick::npv_vec(obs, pred_cls, event_level = "second"), 3)
        f1   <- round(yardstick::f_meas_vec(obs, pred_cls, event_level = "second"), 3)
        kap  <- round(yardstick::kap_vec(obs, pred_cls), 3)

        metricas_df <- data.frame(
          Métrica = c("Sensibilidad", "Especificidad",
                      "VPP (Valor Pred. Positivo)",
                      "VPN (Valor Pred. Negativo)",
                      "F1", "Kappa"),
          Valor = c(sens, spec, ppv, npv, f1, kap),
          Descripción = c(
            "TP / (TP + FN) — detecta positivos",
            "TN / (TN + FP) — detecta negativos",
            "TP / (TP + FP) — precisión al predecir positivo",
            "TN / (TN + FN) — precisión al predecir negativo",
            "Media armónica de sensibilidad y VPP",
            "Concordancia corregida por azar (0=azar, 1=perfecto)"
          )
        )

        tagList(
          h6(paste0("Métricas extendidas (umbral = ", input$umbral, ")")),
          DT::renderDT(
            DT::datatable(metricas_df,
              options = list(dom = "t", pageLength = 10),
              rownames = FALSE) |>
              DT::formatStyle("Valor",
                color = DT::styleInterval(c(0.5, 0.7),
                  c(colores$peligro, colores$advertencia, colores$primario)))
          )
        )
      }, error = function(e)
        div(class = "alert alert-warning", "Métricas no disponibles: ", conditionMessage(e)))
    })

    output$hosmer_lemeshow <- renderUI({
      req(modelo_ajustado())
      tryCatch({
        glm_fit <- workflows::extract_fit_engine(modelo_ajustado()$.workflow[[1]])
        hl <- performance::performance_hosmer(glm_fit, n_bins = 10)
        p_val <- round(hl$p.value, 4)
        chi2  <- round(hl$chisq, 3)
        interp <- if (p_val > 0.05)
          div(class = "alert alert-success small py-2",
            bsicons::bs_icon("check-circle"), " p > 0.05: no se rechaza buen ajuste (calibración aceptable)")
        else
          div(class = "alert alert-warning small py-2",
            bsicons::bs_icon("exclamation-triangle"), " p ≤ 0.05: posible mal ajuste en algunos rangos de probabilidad")

        div(
          h6("Prueba de Hosmer-Lemeshow"),
          div(class = "card",
            div(class = "card-body",
              fluidRow(
                column(6, div(class = "metrica-card",
                  div(class = "metrica-valor", chi2),
                  div(class = "metrica-label", "χ² (10 grupos)"))),
                column(6, div(class = "metrica-card",
                  div(class = "metrica-valor", p_val),
                  div(class = "metrica-label", "p-valor")))
              ),
              br(),
              interp
            )
          )
        )
      }, error = function(e)
        div(class = "alert alert-info small",
          bsicons::bs_icon("info-circle"), " Hosmer-Lemeshow no disponible. Instala el paquete 'performance'."))
    })

    output$plot_roc_performance <- plotly::renderPlotly({
      req(preds_test(), input$var_respuesta)
      df      <- preds_test()
      niveles <- levels(df[[input$var_respuesta]])
      prob_col <- paste0(".pred_", niveles[2])
      if (!prob_col %in% names(df)) prob_col <- names(df)[startsWith(names(df), ".pred_")][2]
      roc_df <- tryCatch({
        r <- pROC::roc(response  = df[[input$var_respuesta]],
                       predictor = df[[prob_col]],
                       levels = niveles, direction = "<", quiet = TRUE)
        data.frame(sens = r$sensitivities, fpr = 1 - r$specificities,
                   auc = as.numeric(r$auc))
      }, error = function(e) NULL)
      if (is.null(roc_df)) return(NULL)
      auc_val <- round(roc_df$auc[1], 3)
      p <- ggplot2::ggplot(roc_df, ggplot2::aes(x = fpr, y = sens)) +
        ggplot2::geom_line(color = colores$primario, linewidth = 1) +
        ggplot2::geom_abline(slope = 1, intercept = 0,
                              linetype = "dashed", color = colores$acento) +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = "1 - Especificidad", y = "Sensibilidad",
                      title = paste0("AUC = ", auc_val))
      plotly::ggplotly(p)
    })

    output$matriz_confusion <- renderUI({
      req(modelo_ajustado(), input$umbral)
      tryCatch({
        wf_fit  <- tune::extract_workflow(modelo_ajustado())
        test    <- rsample::testing(split_datos())
        probs   <- predict(wf_fit, test, type = "prob")
        niveles <- levels(test[[input$var_respuesta]])
        prob_pos <- probs[[paste0(".pred_", niveles[2])]]
        pred_cls <- factor(ifelse(prob_pos >= input$umbral, niveles[2], niveles[1]),
                           levels = niveles)
        cm <- table(Predicho = pred_cls, Observado = test[[input$var_respuesta]])

        div(class = "card",
          div(class = "card-header", paste0("Matriz de confusión (umbral = ", input$umbral, ")")),
          div(class = "card-body",
            tags$table(class = "table table-sm table-bordered text-center",
              tags$thead(
                tags$tr(
                  tags$th(""),
                  lapply(colnames(cm), function(x) tags$th(paste("Obs.", x)))
                )
              ),
              tags$tbody(
                lapply(rownames(cm), function(r) {
                  tags$tr(
                    tags$th(paste("Pred.", r)),
                    lapply(colnames(cm), function(c) {
                      val   <- cm[r, c]
                      color <- if (r == c) "#e8f5e9" else "#ffebee"
                      tags$td(style = paste0("background:", color, ";"), strong(val))
                    })
                  )
                })
              )
            )
          )
        )
      }, error = function(e) div(class = "alert alert-warning", "Matriz no disponible"))
    })

    cv_resultado <- eventReactive(input$btn_cv, {
      req(split_datos(), input$var_respuesta, input$predictores)
      tryCatch({
        train <- rsample::training(split_datos())
        folds <- rsample::vfold_cv(train, v = input$cv_folds,
                                    strata = input$var_respuesta)
        rec <- recipes::recipe(
          as.formula(paste(input$var_respuesta, "~ .")), data = train)
        if (input$step_normalize) rec <- rec |> recipes::step_normalize(recipes::all_numeric_predictors())
        if (input$step_dummy)     rec <- rec |> recipes::step_dummy(recipes::all_nominal_predictors())
        if (input$step_zv)        rec <- rec |> recipes::step_zv(recipes::all_predictors())

        mod <- parsnip::logistic_reg() |>
          parsnip::set_engine("glm") |>
          parsnip::set_mode("classification")

        wf <- workflows::workflow() |>
          workflows::add_recipe(rec) |>
          workflows::add_model(mod)

        res <- tune::fit_resamples(wf, folds,
          metrics = yardstick::metric_set(
            yardstick::roc_auc, yardstick::accuracy))
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
      auc_cv <- m[m$.metric == "roc_auc", ]
      acc_cv <- m[m$.metric == "accuracy", ]
      fluidRow(
        column(6,
          div(class = "card mb-2",
            div(class = "card-body text-center",
              div(style = "font-size:0.85rem; font-weight:600; color:#FC7D0B; text-transform:uppercase;",
                  "AUC-ROC \u2014 CV"),
              div(style = "font-size:2.4rem; font-weight:800; color:#FC7D0B; line-height:1;",
                  round(auc_cv$mean, 3)),
              div(style = "font-size:0.78rem; color:#57606C;",
                  paste0("\u00b1", round(auc_cv$std_err, 3), " (SE)"))
            )
          )
        ),
        column(6,
          div(class = "card mb-2",
            div(class = "card-body text-center",
              div(style = "font-size:0.85rem; font-weight:600; color:#FC7D0B; text-transform:uppercase;",
                  "Accuracy \u2014 CV"),
              div(style = "font-size:2.4rem; font-weight:800; color:#FC7D0B; line-height:1;",
                  round(acc_cv$mean, 3)),
              div(style = "font-size:0.78rem; color:#57606C;",
                  paste0("\u00b1", round(acc_cv$std_err, 3), " (SE)"))
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

    output$plot_roc <- plotly::renderPlotly({
      req(preds_test(), input$var_respuesta)
      df      <- preds_test()
      niveles <- levels(df[[input$var_respuesta]])
      if (length(niveles) < 2) return(NULL)
      prob_col <- paste0(".pred_", niveles[2])
      if (!prob_col %in% names(df)) prob_col <- names(df)[startsWith(names(df), ".pred_")][2]

      roc_df <- tryCatch({
        r <- pROC::roc(response  = df[[input$var_respuesta]],
                       predictor = df[[prob_col]],
                       levels    = niveles, direction = "<")
        data.frame(
          sensibilidad  = r$sensitivities,
          especificidad = 1 - r$specificities,
          auc           = as.numeric(r$auc)
        )
      }, error = function(e) NULL)

      if (is.null(roc_df)) return(NULL)
      auc_val <- round(roc_df$auc[1], 3)
      p <- ggplot2::ggplot(roc_df, ggplot2::aes(x = especificidad, y = sensibilidad)) +
        ggplot2::geom_line(color = colores$primario, linewidth = 1.2) +
        ggplot2::geom_abline(slope = 1, intercept = 0,
                              linetype = "dashed", color = colores$acento) +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = "1 - Especificidad (FPR)", y = "Sensibilidad (TPR)",
                      title = paste0("Curva ROC  |  AUC = ", auc_val))
      plotly::ggplotly(p)
    })

    output$plot_prob_hist <- plotly::renderPlotly({
      req(preds_test(), input$var_respuesta)
      df      <- preds_test()
      niveles <- levels(df[[input$var_respuesta]])
      prob_col <- paste0(".pred_", niveles[2])
      if (!prob_col %in% names(df)) prob_col <- names(df)[startsWith(names(df), ".pred_")][2]
      p <- ggplot2::ggplot(df, ggplot2::aes(x = .data[[prob_col]],
                                             fill = .data[[input$var_respuesta]])) +
        ggplot2::geom_histogram(bins = 30, alpha = 0.7, position = "identity") +
        ggplot2::geom_vline(xintercept = input$umbral, color = colores$peligro,
                             linetype = "dashed", linewidth = 1) +
        scale_fill_tableau_cb() +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = "Probabilidad predicha P(Y=1)", y = "Frecuencia",
                      fill = "Clase observada")
      plotly::ggplotly(p)
    })

    output$tabla_predicciones <- DT::renderDT({
      req(preds_test(), input$var_respuesta, input$umbral)
      df      <- preds_test()
      niveles <- levels(df[[input$var_respuesta]])
      prob_col <- paste0(".pred_", niveles[2])
      if (!prob_col %in% names(df)) prob_col <- names(df)[startsWith(names(df), ".pred_")][2]
      df$Probabilidad <- round(df[[prob_col]], 3)
      df$Predicho <- factor(ifelse(df[[prob_col]] >= input$umbral,
                                   niveles[2], niveles[1]), levels = niveles)
      df$Correcto <- df$Predicho == df[[input$var_respuesta]]
      out <- df[, c(input$var_respuesta, "Probabilidad", "Predicho", "Correcto")]
      names(out)[1] <- "Observado"
      DT::datatable(out,
        options = list(pageLength = 10, scrollX = TRUE, dom = "tip"),
        rownames = FALSE) |>
        DT::formatStyle("Correcto",
          backgroundColor = DT::styleEqual(c(TRUE, FALSE), c("#e8f5e9", "#ffebee")))
    })

    # PESTAÑA 10: Importancia
    # ════════════════════════════════════════════════

    importancia <- reactive({
      req(modelo_ajustado(), input$var_respuesta)
      tryCatch({
        wf_fit  <- tune::extract_workflow(modelo_ajustado())
        train   <- rsample::training(split_datos())
        niveles <- levels(train[[input$var_respuesta]])
        vip::vi(wf_fit,
                method       = "permute",
                target       = input$var_respuesta,
                metric       = "roc_auc",
                event_level  = "second",
                pred_wrapper = function(object, newdata)
                  predict(object, newdata, type = "prob")[[paste0(".pred_", niveles[2])]],
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
        ggplot2::labs(x = "Aumento en AUC (permutaci\u00f3n)", y = NULL,
                      title = "Importancia por permutaci\u00f3n")
      plotly::ggplotly(p)
    })

    output$tabla_importancia <- DT::renderDT({
      req(importancia())
      imp <- importancia()
      imp$Importance <- round(imp$Importance, 4)
      DT::datatable(imp,
        colnames = c("Variable", "Importancia (aumento AUC)"),
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
      wf_fit  <- tune::extract_workflow(modelo_ajustado())
      train   <- rsample::training(split_datos())
      var     <- input$var_pdp
      n_grid  <- input$grid_pdp
      niveles <- levels(train[[input$var_respuesta]])
      prob_col <- paste0(".pred_", niveles[2])

      grid_vals <- if (is.numeric(train[[var]]))
        seq(min(train[[var]], na.rm = TRUE), max(train[[var]], na.rm = TRUE), length.out = n_grid)
      else unique(train[[var]])

      pdp_df <- do.call(rbind, lapply(grid_vals, function(v) {
        df_tmp <- train
        df_tmp[[var]] <- v
        probs  <- predict(wf_fit, df_tmp, type = "prob")
        data.frame(x = v,
                   y_hat = mean(probs[[prob_col]], na.rm = TRUE))
      }))

      p <- ggplot2::ggplot(pdp_df, ggplot2::aes(x = x, y = y_hat)) +
        ggplot2::geom_line(color = colores$primario, linewidth = 1.2) +
        ggplot2::geom_point(color = colores$acento, size = 2) +
        ggplot2::coord_cartesian(ylim = c(0, 1)) +
        ggplot2::theme_minimal() +
        ggplot2::labs(x = var,
                      y = paste0("P(", input$var_respuesta, " = 1) promedio"),
                      title = paste("PDP \u2014", var))
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
      steps_str <- if (length(steps) > 0) paste(steps, collapse = "\n") else ""

      paste0(
        encabezado_script("StatML", "Clasificaci\u00f3n GLM (Regresi\u00f3n Log\u00edstica)"),
        "library(tidymodels)\nlibrary(pROC)\n\n",
        "# Cargar datos\n# datos <- read_excel('tus_datos.xlsx')\n\n",
        "# Asegurar que la respuesta es factor\n",
        "datos$", input$var_respuesta, " <- as.factor(datos$", input$var_respuesta, ")\n\n",
        "# División train/test estratificada\nset.seed(", input$semilla, ")\n",
        "split <- initial_split(datos, prop = ", input$prop_train,
        if (isTRUE(input$strata)) paste0(", strata = '", input$var_respuesta, "'") else "",
        ")\ntrain <- training(split)\ntest  <- testing(split)\n\n",
        "# Receta\nreceta <- recipe(", input$var_respuesta, " ~ ",
        paste(input$predictores, collapse = " + "), ", data = train)",
        if (nchar(steps_str) > 0) paste0(" |>\n", steps_str) else "",
        "\n\n# Modelo\nmodelo <- logistic_reg() |>\n",
        "  set_engine('glm') |>\n  set_mode('classification')\n\n",
        "# Workflow\nwf <- workflow() |>\n",
        "  add_recipe(receta) |>\n  add_model(modelo)\n\n",
        "# Ajuste y evaluación\najuste   <- last_fit(wf, split,\n",
        "  metrics = metric_set(roc_auc, accuracy, sensitivity, specificity))\n",
        "metricas <- collect_metrics(ajuste)\npreds <- collect_predictions(ajuste)\n\n",
        "# Curva ROC\nlibrary(pROC)\nroc(preds$", input$var_respuesta,
        ", preds$.pred_1) |> plot()\n\n",
        "# Importancia\nlibrary(vip)\n",
        "vi(extract_workflow(ajuste), method = 'permute',\n",
        "   target = '", input$var_respuesta, "', metric = 'roc_auc',\n",
        "   event_level = 'second',\n",
        "   pred_wrapper = function(o, nd) predict(o, nd, type = 'prob')$.pred_1,\n",
        "   train = train)\n"
      )
    })

    output$codigo_reproducible <- renderText({ req(codigo_r()); codigo_r() })

    output$btn_descargar_codigo <- downloadHandler(
      filename = function() paste0("StatML_glm_clas_", Sys.Date(), ".R"),
      content  = function(file) writeLines(codigo_r(), file)
    )

  }) # /moduleServer
} # /mod_glm_ml_server
