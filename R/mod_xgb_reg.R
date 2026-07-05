# mod_xgb_reg.R — XGBoost Regresión (StatML)

# UI -------------------------------------------------------------------------
mod_xgb_reg_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::navset_card_tab(
      title = "XGBoost — Regresión",

      # ── 1. ¿Qué es? ──────────────────────────────────────────────────────
      bslib::nav_panel(
        "¿Qué es?",
        icon = bsicons::bs_icon("info-circle"),
        br(),
        h4("XGBoost para regresión"),
        p("XGBoost (eXtreme Gradient Boosting) es un algoritmo de aprendizaje
          automático basado en ", strong("gradient boosting"), ": construye un
          conjunto de árboles de decisión de forma secuencial, donde cada árbol
          nuevo corrige los errores del anterior."),
        p("A diferencia de Random Forest, que construye árboles independientes
          en paralelo, XGBoost aprende de los errores residuales paso a paso.
          Esto lo hace especialmente potente para capturar patrones complejos."),
        hr(),
        h5("Características clave"),
        tags$ul(
          tags$li(strong("Boosting secuencial:"), " cada árbol se entrena sobre los residuos del modelo anterior."),
          tags$li(strong("Regularización:"), " parámetros λ y α controlan la complejidad para evitar sobreajuste."),
          tags$li(strong("Velocidad:"), " implementación muy eficiente con paralelismo a nivel de nodo."),
          tags$li(strong("Hiperparámetros principales:"), " número de árboles (trees), profundidad máxima (tree_depth), tasa de aprendizaje (learn_rate), submuestreo (sample_size).")
        ),
        hr(),
        h5("¿Cuándo usar XGBoost?"),
        tags$ul(
          tags$li("Cuando Random Forest no alcanza la precisión deseada."),
          tags$li("Cuando se dispone de tiempo para ajustar hiperparámetros."),
          tags$li("Datos tabulares con relaciones complejas no lineales."),
          tags$li("Competencias de ciencia de datos (es uno de los algoritmos más ganadores).")
        )
      ),

      # ── 2. Fundamentos ───────────────────────────────────────────────────
      bslib::nav_panel(
        "Fundamentos",
        icon = bsicons::bs_icon("book"),
        br(),
        h4("¿Cómo funciona el Gradient Boosting?"),
        p("El algoritmo minimiza una función de pérdida (e.g., RMSE) añadiendo
          árboles de forma aditiva:"),
        p(em("F_m(x) = F_{m-1}(x) + η · h_m(x)")),
        p("donde ", em("η"), " es la tasa de aprendizaje (learn_rate) y ",
          em("h_m(x)"), " es el árbol ajustado sobre el gradiente negativo de la pérdida."),
        hr(),
        h5("Hiperparámetros principales"),
        tags$dl(
          tags$dt("trees"), tags$dd("Número de árboles (iteraciones de boosting). Más árboles = mayor capacidad, mayor riesgo de sobreajuste."),
          tags$dt("tree_depth"), tags$dd("Profundidad máxima de cada árbol. Controla la complejidad de las interacciones."),
          tags$dt("learn_rate"), tags$dd("Tasa de aprendizaje (η). Valores pequeños (0.01–0.1) + más árboles suelen dar mejor resultado."),
          tags$dt("min_n"), tags$dd("Mínimo de observaciones por nodo hoja."),
          tags$dt("sample_size"), tags$dd("Proporción de datos usados en cada árbol (submuestreo de filas)."),
          tags$dt("mtry"), tags$dd("Proporción de variables muestreadas en cada split (submuestreo de columnas).")
        ),
        hr(),
        h5("Regularización"),
        p("XGBoost incluye términos de regularización en la función objetivo para
          penalizar árboles muy complejos:"),
        tags$ul(
          tags$li(strong("λ (L2):"), " penaliza los pesos grandes de los nodos hoja."),
          tags$li(strong("α (L1):"), " promueve la dispersión (pesos → 0).")
        )
      ),

      # ── 3. Los datos ─────────────────────────────────────────────────────
      bslib::nav_panel(
        "Los datos",
        icon = bsicons::bs_icon("table"),
        bslib::card_body(
          bslib::navset_pill(

            bslib::nav_panel(
              title = tagList(bsicons::bs_icon("collection", class = "me-1"),
                              "Datos de ejemplo"),
              br(),
              bslib::layout_columns(
                col_widths = c(4, 8),
                div(
                  selectInput(ns("dataset"), "Seleccionar dataset:",
                    choices = c(
                      "Biomasa forestal (paisaje)"          = "biomasa_paisaje",
                      "Densidad de aves (paisaje)"          = "aves_densidad_paisaje",
                      "Conteo de aves (paisaje)"            = "aves_conteo_paisaje",
                      "Talla de cangrejo violinista"        = "pie_crab"
                    )
                  ),
                  uiOutput(ns("info_dataset"))
                ),
                bslib::card(
                  bslib::card_header(bsicons::bs_icon("eye", class = "me-1"),
                                     "Vista previa"),
                  bslib::card_body(style = "overflow: auto;",
                    uiOutput(ns("metricas_datos")), br(),
                    DT::DTOutput(ns("tabla_datos"))
                  )
                )
              )
            ),

            bslib::nav_panel(
              title = tagList(bsicons::bs_icon("folder2-open", class = "me-1"),
                              "Mis datos"),
              br(),
              bslib::layout_columns(
                col_widths = c(4, 8),
                div(
                  p(class = "small text-muted mb-3",
                    bsicons::bs_icon("info-circle", class = "me-1"),
                    "Sube un archivo CSV o Excel. ",
                    "La primera fila debe contener los nombres de las columnas."),
                  fileInput(ns("archivo_datos"),
                    label = "Seleccionar archivo:",
                    accept = c(".csv", ".xlsx", ".xls"),
                    buttonLabel = "Buscar\u2026",
                    placeholder = "CSV o Excel"
                  ),
                  selectInput(ns("separador"),
                    label = "Separador (CSV):",
                    choices = c("Coma (,)" = ",", "Punto y coma (;)" = ";",
                                "Tabulador" = "\t"),
                    selected = ","
                  ),
                  tags$hr(),
                  uiOutput(ns("resumen_datos_propio"))
                ),
                bslib::card(
                  bslib::card_header(bsicons::bs_icon("eye", class = "me-1"),
                                     "Vista previa"),
                  bslib::card_body(style = "overflow: auto;",
                    uiOutput(ns("metricas_datos_propio")), br(),
                    DT::DTOutput(ns("tabla_datos_propio"))
                  )
                )
              )
            )
          )
        )
      ),

      # ── 4. Explorar ──────────────────────────────────────────────────────
      bslib::nav_panel(
        "Explorar",
        icon = bsicons::bs_icon("bar-chart"),
        br(),
        fluidRow(
          column(4,
            uiOutput(ns("sel_y_exp")),
            uiOutput(ns("sel_x_exp"))
          )
        ),
        plotOutput(ns("plot_exp"), height = "400px")
      ),

      # ── 5. Preprocesamiento ──────────────────────────────────────────────
      bslib::nav_panel(
        "Preprocesamiento",
        icon = bsicons::bs_icon("sliders"),
        br(),
        fluidRow(
          column(4,
            uiOutput(ns("sel_y_pre")),
            uiOutput(ns("sel_x_pre")),
            hr(),
            sliderInput(ns("prop_train"), "Proporción entrenamiento",
              min = 0.5, max = 0.9, value = 0.75, step = 0.05),
            numericInput(ns("semilla"), "Semilla", value = 123, step = 1),
            hr(),
            checkboxInput(ns("normalizar"), "Normalizar predictores (step_normalize)", value = TRUE),
            checkboxInput(ns("dummies"), "Crear dummies para variables categóricas (step_dummy)", value = TRUE)
          ),
          column(8,
            h5("División de datos"),
            uiOutput(ns("info_split")),
            hr(),
            h5("Receta de preprocesamiento"),
            verbatimTextOutput(ns("info_receta"))
          )
        )
      ),

      # ── 6. Ajustar modelo ────────────────────────────────────────────────
      bslib::nav_panel(
        "Ajustar modelo",
        icon = bsicons::bs_icon("gear"),
        br(),
        fluidRow(
          column(4,
            h5("Tuning de hiperparámetros"),
            p(em("Búsqueda en grilla Latin Hypercube")),
            numericInput(ns("n_grid"), "Combinaciones en la grilla", value = 20, min = 10, max = 50),
            numericInput(ns("cv_folds"), "Folds para validación cruzada", value = 5, min = 3, max = 10),
            hr(),
            p(strong("Rango de búsqueda (valores por defecto de dials):")),
            tags$ul(
              tags$li("trees: 100–2000"),
              tags$li("tree_depth: 1–15"),
              tags$li("learn_rate: 10⁻¹⁰ – 10⁻¹"),
              tags$li("min_n: 2–40"),
              tags$li("sample_size: 0.1–1.0")
            ),
            hr(),
            actionButton(ns("ajustar"), "Ajustar modelo",
              class = "btn-primary btn-lg", width = "100%",
              icon = shiny::icon("play"))
          ),
          column(8,
            h5("Resultado del tuning"),
            plotOutput(ns("plot_tuning"), height = "350px"),
            hr(),
            h5("Mejores hiperparámetros"),
            tableOutput(ns("tabla_best"))
          )
        )
      ),

      # ── 7. Diagnóstico ───────────────────────────────────────────────────
      bslib::nav_panel(
        "Diagnóstico",
        icon = bsicons::bs_icon("heart-pulse"),
        br(),
        h5("Observado vs. Predicho — conjunto de prueba"),
        plotOutput(ns("plot_obs_pred"), height = "380px"),
        hr(),
        h5("Residuos vs. Predicho"),
        plotOutput(ns("plot_residuos"), height = "350px")
      ),

      # ── 8. Performance ───────────────────────────────────────────────────
      bslib::nav_panel(
        "Performance",
        icon = bsicons::bs_icon("speedometer2"),
        br(),
        h5("Métricas de entrenamiento vs. prueba"),
        fluidRow(
          column(6, uiOutput(ns("card_train"))),
          column(6, uiOutput(ns("card_test")))
        ),
        hr(),
        uiOutput(ns("interpretacion_overfitting")),
        hr(),
        h5("Validación cruzada (conjunto de entrenamiento)"),
        tableOutput(ns("tabla_cv"))
      ),

      # ── 9. Predicciones ──────────────────────────────────────────────────
      bslib::nav_panel(
        "Predicciones",
        icon = bsicons::bs_icon("bullseye"),
        br(),
        h5("Predicciones en el conjunto de prueba"),
        DT::DTOutput(ns("tabla_pred")),
        hr(),
        downloadButton(ns("descargar_pred"), "Descargar predicciones (CSV)")
      ),

      # ── 10. Importancia ──────────────────────────────────────────────────
      bslib::nav_panel(
        "Importancia",
        icon = bsicons::bs_icon("star"),
        br(),
        h5("Importancia de variables (permutación, RMSE)"),
        p(em("Algoritmo-agnóstica: mide cuánto aumenta el RMSE al permutar cada variable.")),
        plotOutput(ns("plot_importancia"), height = "400px"),
        hr(),
        tableOutput(ns("tabla_importancia"))
      ),

      # ── 11. PDP ──────────────────────────────────────────────────────────
      bslib::nav_panel(
        "PDP",
        icon = bsicons::bs_icon("graph-up"),
        br(),
        fluidRow(
          column(4,
            uiOutput(ns("sel_pdp_var")),
            numericInput(ns("pdp_grid"), "Puntos en la grilla", value = 30, min = 10, max = 100)
          )
        ),
        plotOutput(ns("plot_pdp"), height = "400px"),
        p(em("PDP (Partial Dependence Plot): efecto marginal promedio de la variable sobre la predicción,
              manteniendo el resto de variables en sus valores observados."))
      ),

      # ── 12. Código R ─────────────────────────────────────────────────────
      bslib::nav_panel(
        "Código R",
        icon = bsicons::bs_icon("code-slash"),
        br(),
        p("Código reproducible para ajustar XGBoost de regresión con tidymodels:"),
        verbatimTextOutput(ns("codigo_r"))
      )
    ) # end navset_card_tab
  )
}


# Server ---------------------------------------------------------------------
mod_xgb_reg_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # ── Datasets disponibles ────────────────────────────────────────────────
    datasets_reg <- list(
      biomasa_paisaje      = "biomasa_paisaje",
      aves_densidad_paisaje = "aves_densidad_paisaje",
      aves_conteo_paisaje  = "aves_conteo_paisaje",
      pie_crab             = "pie_crab"
    )

    datos_raw <- reactive({
      req(input$dataset)
      path <- system.file("app/data", paste0(input$dataset, ".rda"),
                          package = "StatML")
      env <- new.env()
      load(path, envir = env)
      get(ls(env)[1], envir = env)
    })

    # ── Tab 3: Los datos ────────────────────────────────────────────────────
    output$metricas_datos <- renderUI({
      req(datos_raw())
      df <- datos_raw()
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

    output$info_dataset <- renderUI({
      req(input$dataset)
      descripciones <- list(
        biomasa_paisaje        = "Biomasa forestal en 600 sitios. Predictores: precipitaci\u00f3n, temperatura, pH del suelo, nutrientes, altitud.",
        aves_densidad_paisaje  = "Densidad de aves en 600 sitios del paisaje. Variables de cobertura forestal, altitud, temperatura.",
        aves_conteo_paisaje    = "Abundancia de aves en 800 sitios. Relaciones no lineales con cobertura forestal y altitud.",
        pie_crab               = "Ancho del caparaz\u00f3n del cangrejo violinista. Predictores: latitud, temperatura media."
      )
      desc <- descripciones[[input$dataset]]
      if (is.null(desc)) return(NULL)
      div(class = "alert alert-info small py-2 px-3 mt-2 mb-0",
          bsicons::bs_icon("info-circle-fill", class = "me-1"), desc)
    })

    output$tabla_datos <- DT::renderDT({
      DT::datatable(datos_raw(), rownames = FALSE,
        options = list(dom = "t", scrollY = "300px", scrollX = TRUE, paging = FALSE))
    })

    output$resumen_datos <- renderPrint({ summary(datos_raw()) })

    # ── Datos propios ────────────────────────────────────────────────────────
    datos_propio_xgb <- reactive({
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
        showNotification(paste("Error:", conditionMessage(e)), type = "error"); NULL
      })
    })

    output$resumen_datos_propio <- renderUI({
      req(datos_propio_xgb())
      d <- datos_propio_xgb()
      div(class = "small text-muted",
          bsicons::bs_icon("check-circle-fill", class = "me-1"),
          paste0(nrow(d), " filas \u00b7 ", ncol(d), " columnas"))
    })

    output$metricas_datos_propio <- renderUI({
      req(datos_propio_xgb())
      df <- datos_propio_xgb()
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

    output$tabla_datos_propio <- DT::renderDT({
      req(datos_propio_xgb())
      DT::datatable(datos_propio_xgb(), rownames = FALSE,
        options = list(dom = "t", scrollY = "300px", scrollX = TRUE, paging = FALSE))
    })

    # ── Tab 4: Explorar ─────────────────────────────────────────────────────
    vars_num <- reactive({
      names(dplyr::select(datos_raw(), where(is.numeric)))
    })
    output$sel_y_exp <- renderUI({
      selectInput(ns("y_exp"), "Variable respuesta (Y)", choices = vars_num())
    })
    output$sel_x_exp <- renderUI({
      req(input$y_exp)
      selectInput(ns("x_exp"), "Variable predictora (X)",
        choices = setdiff(names(datos_raw()), input$y_exp))
    })
    output$plot_exp <- renderPlot({
      req(input$y_exp, input$x_exp)
      df <- datos_raw()
      x_var <- input$x_exp
      y_var <- input$y_exp
      p <- ggplot2::ggplot(df, ggplot2::aes(x = .data[[x_var]], y = .data[[y_var]]))
      if (is.numeric(df[[x_var]])) {
        p <- p +
          ggplot2::geom_point(alpha = 0.6, color = stat_palette()[1]) +
          ggplot2::geom_smooth(method = "loess", formula = y ~ x,
                               color = stat_palette()[2], se = TRUE)
      } else {
        p <- p +
          ggplot2::geom_boxplot(fill = stat_palette()[1], alpha = 0.6) +
          ggplot2::geom_jitter(width = 0.2, alpha = 0.4, color = stat_palette()[2])
      }
      p + stat_theme() + ggplot2::labs(x = x_var, y = y_var)
    })

    # ── Tab 5: Preprocesamiento ─────────────────────────────────────────────
    output$sel_y_pre <- renderUI({
      selectInput(ns("y_pre"), "Variable respuesta (Y)", choices = vars_num())
    })
    output$sel_x_pre <- renderUI({
      req(input$y_pre)
      checkboxGroupInput(ns("x_pre"), "Variables predictoras (X)",
        choices = setdiff(names(datos_raw()), input$y_pre),
        selected = setdiff(names(datos_raw()), input$y_pre))
    })

    split_obj <- reactive({
      req(input$y_pre, input$x_pre)
      df <- datos_raw()[, c(input$y_pre, input$x_pre), drop = FALSE]
      set.seed(input$semilla)
      rsample::initial_split(df, prop = input$prop_train)
    })
    train_data <- reactive({ rsample::training(split_obj()) })
    test_data  <- reactive({ rsample::testing(split_obj()) })

    output$info_split <- renderUI({
      req(split_obj())
      n_total <- nrow(datos_raw())
      n_train <- nrow(train_data())
      n_test  <- nrow(test_data())
      tagList(
        bslib::value_box("Entrenamiento", paste0(n_train, " obs (", round(n_train/n_total*100), "%)"),
          showcase = bsicons::bs_icon("train-front"), theme = "primary"),
        bslib::value_box("Prueba", paste0(n_test, " obs (", round(n_test/n_total*100), "%)"),
          showcase = bsicons::bs_icon("check2-circle"), theme = "secondary")
      )
    })

    receta <- reactive({
      req(input$y_pre, input$x_pre)
      formula_obj <- stats::as.formula(paste(input$y_pre, "~ ."))
      rec <- recipes::recipe(formula_obj, data = train_data())
      if (input$dummies)    rec <- recipes::step_dummy(rec, recipes::all_nominal_predictors())
      if (input$normalizar) rec <- recipes::step_normalize(rec, recipes::all_numeric_predictors())
      rec <- recipes::step_zv(rec, recipes::all_predictors())
      rec
    })
    output$info_receta <- renderPrint({ receta() })

    # ── Tab 6: Ajustar modelo ───────────────────────────────────────────────
    modelo_final <- reactiveVal(NULL)
    best_params  <- reactiveVal(NULL)
    tune_results <- reactiveVal(NULL)
    wf_final     <- reactiveVal(NULL)

    observeEvent(input$ajustar, {
      req(receta(), train_data())
      withProgress(message = "Ajustando XGBoost...", {

        spec_tune <- parsnip::boost_tree(
          trees      = tune::tune(),
          tree_depth = tune::tune(),
          learn_rate = tune::tune(),
          min_n      = tune::tune(),
          sample_size = tune::tune()
        ) |>
          parsnip::set_engine("xgboost") |>
          parsnip::set_mode("regression")

        wf_tune <- workflows::workflow() |>
          workflows::add_recipe(receta()) |>
          workflows::add_model(spec_tune)

        set.seed(input$semilla)
        cv_folds <- rsample::vfold_cv(train_data(), v = input$cv_folds)
        grilla <- dials::grid_latin_hypercube(
          dials::trees(), dials::tree_depth(), dials::learn_rate(),
          dials::min_n(), dials::sample_size(range = c(0.5, 1.0)),
          size = input$n_grid
        )

        incProgress(0.3, detail = "Buscando hiperparámetros...")
        res <- tune::tune_grid(wf_tune, resamples = cv_folds, grid = grilla,
          metrics = yardstick::metric_set(yardstick::rmse, yardstick::rsq))

        tune_results(res)
        best <- tune::select_best(res, metric = "rmse")
        best_params(best)

        incProgress(0.6, detail = "Ajustando modelo final...")
        wf_final_obj <- tune::finalize_workflow(wf_tune, best)
        fit_final <- parsnip::fit(wf_final_obj, data = train_data())
        wf_final(wf_final_obj)
        modelo_final(fit_final)
      })
    })

    output$plot_tuning <- renderPlot({
      req(tune_results())
      tune::autoplot(tune_results(), metric = "rmse") +
        stat_theme() +
        ggplot2::labs(title = "RMSE por combinación de hiperparámetros")
    })
    output$tabla_best <- renderTable({
      req(best_params())
      best_params() |> dplyr::select(-.config)
    }, digits = 5)

    # ── Predicciones ────────────────────────────────────────────────────────
    preds_test <- reactive({
      req(modelo_final())
      stats::predict(modelo_final(), new_data = test_data()) |>
        dplyr::bind_cols(test_data())
    })
    preds_train <- reactive({
      req(modelo_final())
      stats::predict(modelo_final(), new_data = train_data()) |>
        dplyr::bind_cols(train_data())
    })

    # ── Tab 7: Diagnóstico ──────────────────────────────────────────────────
    output$plot_obs_pred <- renderPlot({
      req(preds_test(), input$y_pre)
      df <- preds_test()
      ggplot2::ggplot(df, ggplot2::aes(x = .data[[input$y_pre]], y = .pred)) +
        ggplot2::geom_point(alpha = 0.6, color = stat_palette()[1]) +
        ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray40") +
        ggplot2::geom_smooth(method = "lm", formula = y ~ x, color = stat_palette()[2], se = FALSE) +
        stat_theme() +
        ggplot2::labs(x = "Observado", y = "Predicho",
                      title = "Observado vs. Predicho — conjunto de prueba")
    })
    output$plot_residuos <- renderPlot({
      req(preds_test(), input$y_pre)
      df <- preds_test() |> dplyr::mutate(.resid = .data[[input$y_pre]] - .pred)
      ggplot2::ggplot(df, ggplot2::aes(x = .pred, y = .resid)) +
        ggplot2::geom_point(alpha = 0.6, color = stat_palette()[1]) +
        ggplot2::geom_hline(yintercept = 0, linetype = "dashed", color = "gray40") +
        ggplot2::geom_smooth(method = "loess", formula = y ~ x,
                             color = stat_palette()[2], se = TRUE) +
        stat_theme() +
        ggplot2::labs(x = "Predicho", y = "Residuo", title = "Residuos vs. Predicho")
    })

    # ── Tab 8: Performance ──────────────────────────────────────────────────
    metricas_train <- reactive({
      req(preds_train(), input$y_pre)
      yardstick::metrics(preds_train(), truth = !!rlang::sym(input$y_pre), estimate = .pred)
    })
    metricas_test <- reactive({
      req(preds_test(), input$y_pre)
      yardstick::metrics(preds_test(), truth = !!rlang::sym(input$y_pre), estimate = .pred)
    })

    output$card_train <- renderUI({
      req(metricas_train())
      m <- metricas_train()
      rmse <- round(m$.estimate[m$.metric == "rmse"], 3)
      r2   <- round(m$.estimate[m$.metric == "rsq"], 3)
      bslib::card(
        bslib::card_header("🔵 Entrenamiento (optimista)", class = "bg-primary text-white"),
        bslib::card_body(
          p(strong("RMSE: "), rmse),
          p(strong("R²: "), r2)
        )
      )
    })
    output$card_test <- renderUI({
      req(metricas_test())
      m <- metricas_test()
      rmse <- round(m$.estimate[m$.metric == "rmse"], 3)
      r2   <- round(m$.estimate[m$.metric == "rsq"], 3)
      bslib::card(
        bslib::card_header("🔴 Prueba (real)", class = "bg-danger text-white"),
        bslib::card_body(
          p(strong("RMSE: "), rmse),
          p(strong("R²: "), r2)
        )
      )
    })
    output$interpretacion_overfitting <- renderUI({
      req(metricas_train(), metricas_test())
      rmse_train <- metricas_train()$.estimate[metricas_train()$.metric == "rmse"]
      rmse_test  <- metricas_test()$.estimate[metricas_test()$.metric == "rmse"]
      diff_rel   <- abs(rmse_test - rmse_train) / rmse_train
      nivel <- if (diff_rel < 0.05) {
        list(color = "success", texto = "Excelente", desc = "Diferencia < 5%: el modelo generaliza muy bien.")
      } else if (diff_rel < 0.10) {
        list(color = "warning", texto = "Aceptable", desc = "Diferencia 5–10%: generalización razonable.")
      } else {
        list(color = "danger", texto = "Posible sobreajuste", desc = "Diferencia > 10%: considerar mayor regularización o menos árboles.")
      }
      bslib::card(
        bslib::card_header(paste("Diagnóstico de generalización:", nivel$texto),
          class = paste0("bg-", nivel$color, " text-white")),
        bslib::card_body(
          p(nivel$desc),
          p(strong("RMSE entrenamiento: "), round(rmse_train, 3), " | ",
            strong("RMSE prueba: "), round(rmse_test, 3), " | ",
            strong("Diferencia relativa: "), scales::percent(diff_rel, accuracy = 0.1))
        )
      )
    })
    output$tabla_cv <- renderTable({
      req(tune_results(), best_params())
      tune::collect_metrics(tune_results()) |>
        dplyr::filter(.metric == "rmse") |>
        dplyr::arrange(mean) |>
        dplyr::slice_head(n = 5) |>
        dplyr::select(trees, tree_depth, learn_rate, min_n, mean, std_err) |>
        dplyr::rename("RMSE (CV)" = mean, "SE" = std_err)
    }, digits = 4)

    # ── Tab 9: Predicciones ─────────────────────────────────────────────────
    output$tabla_pred <- DT::renderDT({
      req(preds_test())
      DT::datatable(
        preds_test() |> dplyr::select(.pred, dplyr::everything()),
        options = list(pageLength = 10, scrollX = TRUE)
      )
    })
    output$descargar_pred <- downloadHandler(
      filename = function() paste0("xgb_reg_predicciones_", Sys.Date(), ".csv"),
      content  = function(file) utils::write.csv(preds_test(), file, row.names = FALSE)
    )

    # ── Tab 10: Importancia ─────────────────────────────────────────────────
    importancia <- reactive({
      req(modelo_final(), train_data(), input$y_pre)
      vip::vi(modelo_final(), method = "permute",
        train  = train_data(),
        target = input$y_pre,
        metric = "rmse",
        pred_wrapper = function(object, newdata) {
          stats::predict(object, new_data = newdata)$.pred
        }
      )
    })
    output$plot_importancia <- renderPlot({
      req(importancia())
      importancia() |>
        dplyr::slice_max(Importance, n = 15) |>
        ggplot2::ggplot(ggplot2::aes(x = Importance,
                                      y = reorder(Variable, Importance))) +
        ggplot2::geom_col(fill = stat_palette()[1]) +
        stat_theme() +
        ggplot2::labs(x = "Importancia (RMSE)", y = NULL,
                      title = "Importancia de variables — permutación")
    })
    output$tabla_importancia <- renderTable({
      req(importancia())
      importancia() |> dplyr::arrange(dplyr::desc(Importance))
    }, digits = 4)

    # ── Tab 11: PDP ─────────────────────────────────────────────────────────
    output$sel_pdp_var <- renderUI({
      req(importancia())
      top_var <- importancia() |>
        dplyr::slice_max(Importance, n = 1) |>
        dplyr::pull(Variable)
      selectInput(ns("pdp_var"), "Variable para PDP",
        choices  = importancia()$Variable,
        selected = top_var)
    })
    output$plot_pdp <- renderPlot({
      req(modelo_final(), train_data(), input$pdp_var)
      df <- train_data()
      var <- input$pdp_var
      x_seq <- if (is.numeric(df[[var]])) {
        seq(min(df[[var]], na.rm = TRUE), max(df[[var]], na.rm = TRUE),
            length.out = input$pdp_grid)
      } else {
        unique(df[[var]])
      }
      pd_df <- purrr::map_dfr(x_seq, function(val) {
        df_tmp <- df
        df_tmp[[var]] <- val
        preds <- stats::predict(modelo_final(), new_data = df_tmp)$.pred
        tibble::tibble(x = val, yhat = mean(preds, na.rm = TRUE))
      })
      p <- ggplot2::ggplot(pd_df, ggplot2::aes(x = x, y = yhat))
      if (is.numeric(df[[var]])) {
        p <- p + ggplot2::geom_line(color = stat_palette()[1], linewidth = 1.2) +
                 ggplot2::geom_rug(data = df, ggplot2::aes(x = .data[[var]]),
                                   sides = "b", alpha = 0.3, inherit.aes = FALSE)
      } else {
        p <- p + ggplot2::geom_col(fill = stat_palette()[1])
      }
      p + stat_theme() +
        ggplot2::labs(x = var, y = paste("Predicción promedio de", input$y_pre),
                      title = paste("PDP —", var))
    })

    # ── Tab 12: Código R ────────────────────────────────────────────────────
    output$codigo_r <- renderText({
      req(input$y_pre, input$x_pre)
      vars_str <- paste0('c("', paste(input$x_pre, collapse = '", "'), '")')
      glue::glue('
library(tidymodels)
library(vip)

# Datos
data("your_dataset")
df <- your_dataset[, c("{input$y_pre}", {vars_str})]

# División
set.seed({input$semilla})
split  <- initial_split(df, prop = {input$prop_train})
train  <- training(split)
test   <- testing(split)

# Receta
rec <- recipe({input$y_pre} ~ ., data = train) |>
  step_dummy(all_nominal_predictors()) |>
  step_normalize(all_numeric_predictors()) |>
  step_zv(all_predictors())

# Especificación con tuning
spec <- boost_tree(
  trees       = tune(),
  tree_depth  = tune(),
  learn_rate  = tune(),
  min_n       = tune(),
  sample_size = tune()
) |>
  set_engine("xgboost") |>
  set_mode("regression")

# Workflow
wf <- workflow() |>
  add_recipe(rec) |>
  add_model(spec)

# Grilla y CV
set.seed({input$semilla})
folds  <- vfold_cv(train, v = {input$cv_folds})
grilla <- grid_latin_hypercube(
  trees(), tree_depth(), learn_rate(),
  min_n(), sample_size(range = c(0.5, 1.0)),
  size = {input$n_grid}
)

# Tuning
res  <- tune_grid(wf, resamples = folds, grid = grilla,
                  metrics = metric_set(rmse, rsq))
best <- select_best(res, metric = "rmse")

# Modelo final
wf_final <- finalize_workflow(wf, best)
fit      <- fit(wf_final, data = train)

# Métricas
predict(fit, new_data = test) |>
  bind_cols(test) |>
  metrics(truth = {input$y_pre}, estimate = .pred)

# Importancia (permutación)
vi(fit, method = "permute",
   train  = train,
   target = "{input$y_pre}",
   metric = "rmse",
   pred_wrapper = function(object, newdata) predict(object, new_data = newdata)$.pred)
      ')
    })

  }) # end moduleServer
}
